require "net/http"
require "json"

class DataGouvService
  TABULAR_BASE = "https://tabular-api.data.gouv.fr/api/resources"
  DIDO_BASE = "https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles"
  TIMEOUT = 10

  DIDO_RESOURCES = {
    immat_occasion: "e1ce0075-1e89-4c96-afab-167a2bbd4b3f",
    parc_vehicules: "37dd7056-6c4d-44e0-a720-32d4064f9a26"
  }.freeze

  RESOURCES = {
    exchange_rates: "2879b159-aba1-4563-b1b7-7334eb861255",
    prix_carburant: "c6ab9d8e-8095-40b2-950b-386f41ab2e5d",
    irve_bornes: "eb76d20a-8501-400e-b336-d85724de5435",
    prix_ct: "63b62549-6c19-465f-a97c-2c65e9550d8a",
    annuaire_ct: "084786fd-7cf5-4a18-86a4-4c4313ad11a7"
  }.freeze

  def exchange_rate(currency, date: nil)
    resource_id = RESOURCES[:exchange_rates]
    params = { "CURRENCY__exact" => currency, "FREQ__exact" => "D", "EXR_TYPE__exact" => "SP00", "page_size" => "1" }
    params["time_period__exact"] = date if date.present?

    rows = fetch_tabular(resource_id, params)
    return nil if rows.empty?

    obs_value = rows.first["obs_value"].to_f
    return nil if obs_value <= 0

    (1.0 / obs_value).round(4)
  end

  def latest_exchange_rates
    resource_id = RESOURCES[:exchange_rates]
    rows = fetch_tabular(resource_id, { "page_size" => "30" })
    return {} if rows.empty?

    target_currencies = %w[CHF GBP JPY USD]
    rows.each_with_object({}) do |row, rates|
      currency = row["CURRENCY"]
      next unless target_currencies.include?(currency)
      obs_value = row["obs_value"].to_f
      next if obs_value <= 0
      rates[currency] = (1.0 / obs_value).round(4)
    end
  end

  def fuel_prices(department_code)
    params = { "page_size" => "50" }
    params["Département__exact"] = department_code if department_code.present?

    rows = fetch_tabular(RESOURCES[:prix_carburant], params)
    rows.map do |row|
      {
        name: row["Nom"],
        address: row["Adresse"],
        city: row["Ville"],
        department: row["Département"],
        gazole: row["Prix Gazole"]&.to_f,
        sp95: row["Prix SP95"]&.to_f,
        sp98: row["Prix SP98"]&.to_f,
        e10: row["Prix E10"]&.to_f,
        e85: row["Prix E85"]&.to_f,
        gplc: row["Prix GPLc"]&.to_f
      }
    end
  end

  def fuel_price_average(department_code, fuel_type = :gazole)
    stations = fuel_prices(department_code)
    prices = stations.map { |s| s[fuel_type] }.compact.select { |p| p > 0 }
    return nil if prices.empty?

    {
      avg: (prices.sum / prices.size).round(3),
      min: prices.min,
      max: prices.max,
      stations_count: prices.size
    }
  end

  def charging_stations(commune_code: nil, department_code: nil, page_size: 20)
    params = { "page_size" => page_size.to_s }
    params["code_insee_commune__exact"] = commune_code if commune_code.present?

    rows = fetch_tabular(RESOURCES[:irve_bornes], params)
    rows.map do |row|
      {
        name: row["nom_station"],
        operator: row["nom_operateur"],
        address: row["adresse_station"],
        commune: row["consolidated_commune"],
        power_kw: row["puissance_nominale"]&.to_f,
        type_2: row["prise_type_2"] == "true",
        combo_ccs: row["prise_type_combo_ccs"] == "true",
        chademo: row["prise_type_chademo"] == "true",
        lat: row["consolidated_latitude"]&.to_f,
        lng: row["consolidated_longitude"]&.to_f
      }
    end
  end

  def ct_price(department_code)
    params = { "page_size" => "50", "cat_vehicule_id__exact" => "1" }
    params["code_departement__exact"] = department_code if department_code.present?

    rows = fetch_tabular(RESOURCES[:prix_ct], params)
    prices = rows.map { |r| r["prix_visite"] }.compact.select { |p| p > 0 }
    return nil if prices.empty?

    {
      avg: (prices.sum / prices.size).round(0),
      min: prices.min,
      max: prices.max,
      centers_count: prices.size
    }
  end

  def immatriculations_occasion(commune_code, millesime: "2026-02")
    fetch_dido(DIDO_RESOURCES[:immat_occasion], { "COMMUNE_CODE" => "eq:#{commune_code}" }, millesime)
  end

  def parc_vehicules(commune_code, vehicle_class: "vp", millesime: "2023-05")
    fetch_dido(DIDO_RESOURCES[:parc_vehicules], {
      "COMMUNE_CODE" => "eq:#{commune_code}",
      "CLASSE_VEHICULE" => "in:#{vehicle_class}"
    }, millesime)
  end

  def market_trend(commune_code)
    rows = immatriculations_occasion(commune_code)
    return nil if rows.empty?

    years = {}
    by_fuel = {}

    rows.each do |row|
      fuel = row["CARBURANT"] || "Inconnu"
      by_fuel[fuel] ||= {}

      (2015..2025).each do |y|
        count = row["IMMAT_#{y}"].to_i
        years[y] = (years[y] || 0) + count
        by_fuel[fuel][y] = (by_fuel[fuel][y] || 0) + count
      end
    end

    { commune: rows.first["COMMUNE_NOM"], years: years, by_fuel: by_fuel }
  end

  private

  def fetch_dido(datafile_rid, filters = {}, millesime = nil)
    uri = URI("#{DIDO_BASE}/#{datafile_rid}/json")
    params = {}
    params["millesime"] = millesime if millesime.present?
    filters.each { |k, v| params[k] = v }
    uri.query = URI.encode_www_form(params)

    response = make_request(uri)
    return [] unless response

    data = JSON.parse(response)
    Array(data)
  rescue JSON::ParserError => e
    Rails.logger.error("DiDo JSON parse error: #{e.message}")
    []
  end

  def fetch_tabular(resource_id, params = {})
    uri = URI("#{TABULAR_BASE}/#{resource_id}/data/")
    uri.query = URI.encode_www_form(params)

    response = make_request(uri)
    return [] unless response

    data = JSON.parse(response)
    data["data"] || []
  rescue JSON::ParserError => e
    Rails.logger.error("DataGouv JSON parse error: #{e.message}")
    []
  end

  def make_request(uri)
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true,
                    open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
      response = http.request(request)
      return response.body if response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("DataGouv API #{response.code}: #{uri}")
    end
    nil
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("DataGouv API timeout: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("DataGouv API error: #{e.message}")
    nil
  end
end
