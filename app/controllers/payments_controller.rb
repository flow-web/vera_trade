class PaymentsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery except: [:stripe_webhook, :coinbase_webhook]
  
  def create_checkout
    @amount = params[:amount].to_i
    
    if @amount < 10
      flash[:error] = "Le montant minimum est de 10€"
      redirect_to dashboard_wallet_path
      return
    end
    
    begin
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        customer_email: current_user.email,
        line_items: [{
          price_data: {
            currency: 'eur',
            product_data: {
              name: 'Rechargement portefeuille Vera Trade',
            },
            unit_amount: @amount * 100,
          },
          quantity: 1,
        }],
        metadata: {
          user_id: current_user.id,
          wallet_recharge: true
        },
        mode: 'payment',
        success_url: dashboard_wallet_url + "?success=true&session_id={CHECKOUT_SESSION_ID}",
        cancel_url: dashboard_wallet_url + "?canceled=true",
      )
      
      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      flash[:error] = "Une erreur est survenue: #{e.message}"
      redirect_to dashboard_wallet_path
    end
  end
  
  def create_crypto_charge
    @amount = params[:amount].to_i
    
    if @amount < 10
      flash[:error] = "Le montant minimum est de 10€"
      redirect_to dashboard_wallet_path
      return
    end
    
    begin
      charge = CoinbaseCommerce::Checkout.create(
        name: "Vera Trade - Rechargement portefeuille",
        description: "Rechargement du portefeuille Vera Trade",
        pricing_type: "fixed_price",
        local_price: {
          amount: @amount.to_s,
          currency: "EUR"
        },
        metadata: {
          user_id: current_user.id,
          wallet_recharge: true
        },
        redirect_url: dashboard_wallet_url + "?success=true&crypto=true",
        cancel_url: dashboard_wallet_url + "?canceled=true&crypto=true",
      )
      
      redirect_to charge.hosted_url, allow_other_host: true
    rescue => e
      flash[:error] = "Une erreur est survenue avec Coinbase: #{e.message}"
      redirect_to dashboard_wallet_path
    end
  end
  
  def stripe_webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret]
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end
    
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      
      if session.metadata.wallet_recharge == 'true'
        user = User.find(session.metadata.user_id)
        amount_cents = session.amount_total
        
        if user && user.wallet
          user.wallet.add_funds(amount_cents, reference: session.id)
        end
      end
    end
    
    head :ok
  end
  
  def coinbase_webhook
    payload = request.body.read
    signature = request.headers["X-CC-Webhook-Signature"]
    shared_secret = Rails.application.credentials.coinbase[:webhook_secret]
    
    begin
      event = CoinbaseCommerce::Webhook.construct_event(payload, signature, shared_secret)
    rescue JSON::ParserError => e
      return head :bad_request
    rescue CoinbaseCommerce::Errors::SignatureVerificationError => e
      return head :bad_request
    end
    
    if event.type == 'charge:confirmed'
      charge = event.data
      
      if charge.metadata.wallet_recharge == 'true'
        user = User.find(charge.metadata.user_id)
        amount_cents = (charge.pricing.local.amount.to_f * 100).to_i
        
        if user && user.wallet
          user.wallet.add_funds(amount_cents, reference: charge.id)
        end
      end
    end
    
    head :ok
  end
end 