class HelpController < ApplicationController
  before_action :authenticate_user!

  def index
    @recent_disputes = current_user.disputes.recent.limit(5)
    @recent_tickets = current_user.support_tickets.recent.limit(5)
  end

  def dispute_guidelines
    # This action renders the dispute guidelines view
  end

  def support_faq
    @faqs = build_faq_data
  end

  private

  def build_faq_data
    [
      {
        category: "Compte et connexion",
        questions: [
          {
            question: "Comment réinitialiser mon mot de passe ?",
            answer: "Cliquez sur 'Mot de passe oublié' sur la page de connexion et suivez les instructions envoyées par email."
          },
          {
            question: "Comment modifier mes informations personnelles ?",
            answer: "Rendez-vous dans votre profil utilisateur via le menu principal pour modifier vos informations."
          },
          {
            question: "Comment supprimer mon compte ?",
            answer: "Contactez notre support via un ticket pour demander la suppression de votre compte."
          }
        ]
      },
      {
        category: "Litiges",
        questions: [
          {
            question: "Dans quels cas puis-je ouvrir un litige ?",
            answer: "Vous pouvez ouvrir un litige en cas de produit non conforme, de service non rendu, de problème de paiement ou de fraude."
          },
          {
            question: "Combien de temps ai-je pour ouvrir un litige ?",
            answer: "Vous avez 30 jours après la transaction ou la découverte du problème pour ouvrir un litige."
          },
          {
            question: "Que se passe-t-il si l'autre partie ne répond pas ?",
            answer: "Après 7 jours sans réponse, vous pouvez escalader le litige vers la médiation."
          }
        ]
      },
      {
        category: "Support technique",
        questions: [
          {
            question: "Le site ne fonctionne pas correctement, que faire ?",
            answer: "Vérifiez votre connexion internet, videz le cache de votre navigateur, ou contactez le support technique."
          },
          {
            question: "Comment signaler un bug ?",
            answer: "Créez un ticket de support de type 'Problème technique' avec une description détaillée du problème."
          },
          {
            question: "L'application mobile est-elle disponible ?",
            answer: "Actuellement, VeraTrade est optimisé pour les navigateurs mobiles. Une application native est en développement."
          }
        ]
      },
      {
        category: "Paiements et facturation",
        questions: [
          {
            question: "Quels moyens de paiement sont acceptés ?",
            answer: "Nous acceptons les cartes bancaires, PayPal et les virements bancaires pour certaines transactions."
          },
          {
            question: "Comment demander un remboursement ?",
            answer: "Les remboursements se font via le système de litiges ou en contactant directement le vendeur."
          },
          {
            question: "Y a-t-il des frais de service ?",
            answer: "Des frais de service peuvent s'appliquer selon le type de transaction. Consultez nos conditions générales."
          }
        ]
      }
    ]
  end
end
