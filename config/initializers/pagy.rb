# Pagy pagination config — https://github.com/ddnexus/pagy
#
# PR1 catalogue-search wires pagy into ListingsController#index. Controller
# pulls in Pagy::Backend; ApplicationHelper pulls in Pagy::Frontend for the
# view helpers (pagy_nav, pagy_info, etc.).

# Default items-per-page (overridden per-call with `pagy(..., limit: N)`).
Pagy::DEFAULT[:limit] = 12

# When an out-of-range page is requested (e.g. ?page=9999 with 3 pages),
# fall back to the last valid page instead of raising Pagy::OverflowError.
# Shareable URLs stay useful after the catalog grows or shrinks.
Pagy::DEFAULT[:overflow] = :last_page

# Preserve query-string params across page links so filters survive pagination.
# (Pagy passes the existing params by default when using pagy_url_for, which
# all the frontend helpers call internally.)
Pagy::DEFAULT[:params] = ->(params) { params }
