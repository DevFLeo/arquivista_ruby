Rails.application.routes.draw do
  get "pages/home"
  # A Landing Page será a porta de entrada principal
  root "pages#home"

  # O Dashboard será uma rota específica
  get "dashboard", to: "dashboard#index"

  # Rota de verificação de saúde do app
  get "up" => "rails/health#show", as: :rails_health_check

  # Arquivos para PWA (Progressive Web App)
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
