# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql_dev"
  end
  post "/graphql", to: "graphql#execute"
  post "/graphql_jwt", to: "graphql#execute_jwt"
  post "/graphql_dev", to: "graphql#execute_dev" if Rails.env.development?

  mount RailsAdmin::Engine => "/super_admin", :as => "rails_admin"

  resources :field_providers
  resources :admins
  resources :admin_notes
  resources :zones
  resources :providers

  devise_scope :user do
    get "users/check_session_timeout", to: "users/session_timeouts#check_session_timeout"
    get "users/session_timeout", to: "users/session_timeouts#render_timeout"
    delete "users/sign_out", to: "users/sessions#destroy"
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  get "/sso_failure", to: redirect("sso_failure.html")
  get "/sfdc_scheduler_iframe_demo", to: "sfdc_external#scheduler_entrypoint"

  namespace :users do
    resource :invites, only: %i[show update]
  end

  namespace :admin do
    resources :tags
    get "visits", to: "appointments#visit_index", defaults: {local_view: "list"}
    get "visits/calendar", to: "appointments#visit_index", defaults: {local_view: "calendar"}
    get "visits/map", to: "appointments#index_two", defaults: {local_view: "map"}
    get "background_job_results", to: "background_job_results#index"
    get "polling/patients_worklist/:type", to: "polling#patients_worklist", as: "patients_worklist_polling"
    get "kustomer/patients/new", to: "kustomer#new_patients"
    post "kustomer/patients/create", to: "kustomer#create_patients"
    post "alayacare/create", to: "alayacare#create_visit"
    get "alayacare/field_providers", to: "alayacare#field_providers"
    post "visits", to: "patients#visit_notes"

    namespace :capacity do
      get :availability
      get :get_availability_by_date
    end

    namespace :alayacare do
      get :patient_visits_partial
      get :cancel_visit_partial
      post :cancel_visit
      put :edit_visit
      post :incoming_event
    end

    resources :appointments, only: %i[index show edit update new create] do
      get :edit_partial, on: :member
      post :admin_notes, on: :member
      post :tags, on: :member
      post :fetch_clinical_summary, on: :member
      post :send_pdf, on: :member
      post :visit_results, on: :member
      get :render_visit_summary_pdf, on: :member
    end
    resources :patients, only: %i[index show create edit update new] do
      post :admin_notes, on: :member
      get :history, on: :member
      put :update_status, on: :member
      get :alayacare_visit, on: :member
      get :fetch_suggested_visits, on: :member
      get :fetch_visit_param_info
      get :edit_visit_partial, on: :member
      get :visit_types, on: :member
      resources :visits, only: [:index]
    end
    resources :field_orgs, only: %i[index show] do
      post :invite_users, on: :member
    end
    resources :demand_partners, only: %i[index show]
    resources :users, only: %i[index create show update] do
      get :edit_partial, on: :member
      get :invited, on: :collection, to: "users#index", defaults: {show_invited: true}
      post :resend_invite, on: :member
    end

    resources :field_users, only: [] do
      collection do
        get "import"
        post "preview_import"
        post "submit_import"
      end
    end

    resources :hra_surveys, only: %i[index]

    resources :patient_prospects, only: %i[index destroy show]

    resources :visits, only: %i[update]

    resources :outreach_campaigns, only: %i[index] do
      member do
        post "send_one"
      end
    end

    root to: "patients#index"
  end

  namespace :field do
    root to: "patients#index"
    get "visits"
    post :cancel_visit, to: "visits#cancel_visit"
    get :cancel_visit_partial, to: "visits#cancel_visit_partial"
    resources :visits, only: %i[update]

    resources :appointments, only: %i[index show update] do
      resources :hra_surveys, only: %i[create new]
      resources :surveys, only: %i[show] do
        post :respond, on: :member
      end
      resources :extra_vaccine_recipients, only: %i[edit update]
    end

    resources :patients, only: %i[index show create edit update new] do
      post :admin_notes, on: :member
      get :history, on: :member
      put :update_status, on: :member
      get :alayacare_visit, on: :member
      get :fetch_suggested_visits, on: :member
      get :fetch_visit_param_info
      get :edit_visit_partial, on: :member
      get :visit_types, on: :member
      resources :visits, only: [:index]
    end

    namespace :capacity do
      get :availability
      get :get_availability_by_date
    end
  end



  namespace :dashboard do
    namespace :field_admin do
      root to: redirect("/dashboard/field_admin/users/office_users")

      resources :users, only: %i[index new create] do
        collection do
          get "office_users"
          get "field_providers"
        end

        member do
          post "resend_invite"
        end
      end
    end
  end

  get "data_import/new_data_import"
  post "data_import/data_import"

  get "visit_routing/new_visit"
  post "visit_routing/get_options"

  get "alayacare_control_panel/index"
  post "alayacare_control_panel/sync_demand_partner_ids"
  post "alayacare_control_panel/sync_cancel_code_ids"
  post "alayacare_control_panel/sync_service_ids"
  post "alayacare_control_panel/dedup_mrns"
  post "alayacare_control_panel/backfill_field_providers"

  post "alayacare_control_panel/sync_visit_types"
  post "alayacare_control_panel/clear_caches"
  post "alayacare_control_panel/backfill_visits"

  get "athena_control_panel/index"
  post "athena_control_panel/sync_department_ids"
  post "athena_control_panel/sync_cancel_code_ids"
  post "athena_control_panel/sync_service_ids"
  post "athena_control_panel/sync_visit_type_ids"
  post "athena_control_panel/sync_custom_field_ids"
  post "athena_control_panel/sync_field_provider_ids"
  post "athena_control_panel/initialize_regression_fixtures"

  get "papertrail/:type/:id", to: "papertrail#show_history"

  root "application#redirect_to_home_page"

  mount RailsEventStore::Browser => "/res" if Rails.env.development?

  constraints CanAccessSuperAdminRoutes do
    mount Flipper::UI.app(Flipper) => '/flipper', as: "flipper"
  end

  authenticated :user, -> user { user.is_super_admin? } do
    match "/delayed_job" => DelayedJobWeb, anchor: false, via: [:get, :post]
  end

  # basic health check
  get "/health", to: "application#health_check"

  namespace :jwt_web do
    get "scheduler/new"
    get "scheduler/reschedule"
  end

  namespace :api do
    namespace :v1 do
      resources :visits

      post "/visit_event", to: "visit_event#create"
      get "/visit_event", to: "visit_event#show"
    end
  end

  post "inbound/lambdaforce", to: "lambdaforce#inbound" # Retained to ensure compatibility until LambdaForce is updated to use the new route
  post "lambdaforce/inbound", to: "lambdaforce#inbound"
  post "lambdaforce/emit/:ma_id", to: "lambdaforce#emit"
end

# typed: true
# typed: true

# == Route Map
#
#                                              Prefix Verb     URI Pattern                                                                                       Controller#Action
#                                      graphiql_rails          /graphiql                                                                                         GraphiQL::Rails::Engine {:graphql_path=>"/graphql_dev"}
#                                             graphql POST     /graphql(.:format)                                                                                graphql#execute
#                                         graphql_jwt POST     /graphql_jwt(.:format)                                                                            graphql#execute_jwt
#                                         graphql_dev POST     /graphql_dev(.:format)                                                                            graphql#execute_dev
#                                         rails_admin          /super_admin                                                                                      RailsAdmin::Engine
#                                     field_providers GET      /field_providers(.:format)                                                                        field_providers#index
#                                                     POST     /field_providers(.:format)                                                                        field_providers#create
#                                  new_field_provider GET      /field_providers/new(.:format)                                                                    field_providers#new
#                                 edit_field_provider GET      /field_providers/:id/edit(.:format)                                                               field_providers#edit
#                                      field_provider GET      /field_providers/:id(.:format)                                                                    field_providers#show
#                                                     PATCH    /field_providers/:id(.:format)                                                                    field_providers#update
#                                                     PUT      /field_providers/:id(.:format)                                                                    field_providers#update
#                                                     DELETE   /field_providers/:id(.:format)                                                                    field_providers#destroy
#                                              admins GET      /admins(.:format)                                                                                 admins#index
#                                                     POST     /admins(.:format)                                                                                 admins#create
#                                           new_admin GET      /admins/new(.:format)                                                                             admins#new
#                                          edit_admin GET      /admins/:id/edit(.:format)                                                                        admins#edit
#                                               admin GET      /admins/:id(.:format)                                                                             admins#show
#                                                     PATCH    /admins/:id(.:format)                                                                             admins#update
#                                                     PUT      /admins/:id(.:format)                                                                             admins#update
#                                                     DELETE   /admins/:id(.:format)                                                                             admins#destroy
#                                         admin_notes GET      /admin_notes(.:format)                                                                            admin_notes#index
#                                                     POST     /admin_notes(.:format)                                                                            admin_notes#create
#                                      new_admin_note GET      /admin_notes/new(.:format)                                                                        admin_notes#new
#                                     edit_admin_note GET      /admin_notes/:id/edit(.:format)                                                                   admin_notes#edit
#                                          admin_note GET      /admin_notes/:id(.:format)                                                                        admin_notes#show
#                                                     PATCH    /admin_notes/:id(.:format)                                                                        admin_notes#update
#                                                     PUT      /admin_notes/:id(.:format)                                                                        admin_notes#update
#                                                     DELETE   /admin_notes/:id(.:format)                                                                        admin_notes#destroy
#                                               zones GET      /zones(.:format)                                                                                  zones#index
#                                                     POST     /zones(.:format)                                                                                  zones#create
#                                            new_zone GET      /zones/new(.:format)                                                                              zones#new
#                                           edit_zone GET      /zones/:id/edit(.:format)                                                                         zones#edit
#                                                zone GET      /zones/:id(.:format)                                                                              zones#show
#                                                     PATCH    /zones/:id(.:format)                                                                              zones#update
#                                                     PUT      /zones/:id(.:format)                                                                              zones#update
#                                                     DELETE   /zones/:id(.:format)                                                                              zones#destroy
#                                           providers GET      /providers(.:format)                                                                              providers#index
#                                                     POST     /providers(.:format)                                                                              providers#create
#                                        new_provider GET      /providers/new(.:format)                                                                          providers#new
#                                       edit_provider GET      /providers/:id/edit(.:format)                                                                     providers#edit
#                                            provider GET      /providers/:id(.:format)                                                                          providers#show
#                                                     PATCH    /providers/:id(.:format)                                                                          providers#update
#                                                     PUT      /providers/:id(.:format)                                                                          providers#update
#                                                     DELETE   /providers/:id(.:format)                                                                          providers#destroy
#                         users_check_session_timeout GET      /users/check_session_timeout(.:format)                                                            users/session_timeouts#check_session_timeout
#                               users_session_timeout GET      /users/session_timeout(.:format)                                                                  users/session_timeouts#render_timeout
#                                      users_sign_out DELETE   /users/sign_out(.:format)                                                                         users/sessions#destroy
#                                    new_user_session GET      /users/sign_in(.:format)                                                                          devise/sessions#new
#                                        user_session POST     /users/sign_in(.:format)                                                                          devise/sessions#create
#                                destroy_user_session DELETE   /users/sign_out(.:format)                                                                         devise/sessions#destroy
#                   user_oktaoauth_omniauth_authorize GET|POST /users/auth/oktaoauth(.:format)                                                                   users/omniauth_callbacks#passthru
#                    user_oktaoauth_omniauth_callback GET|POST /users/auth/oktaoauth/callback(.:format)                                                          users/omniauth_callbacks#oktaoauth
#                                   new_user_password GET      /users/password/new(.:format)                                                                     devise/passwords#new
#                                  edit_user_password GET      /users/password/edit(.:format)                                                                    devise/passwords#edit
#                                       user_password PATCH    /users/password(.:format)                                                                         devise/passwords#update
#                                                     PUT      /users/password(.:format)                                                                         devise/passwords#update
#                                                     POST     /users/password(.:format)                                                                         devise/passwords#create
#                            cancel_user_registration GET      /users/cancel(.:format)                                                                           devise/registrations#cancel
#                               new_user_registration GET      /users/sign_up(.:format)                                                                          devise/registrations#new
#                              edit_user_registration GET      /users/edit(.:format)                                                                             devise/registrations#edit
#                                   user_registration PATCH    /users(.:format)                                                                                  devise/registrations#update
#                                                     PUT      /users(.:format)                                                                                  devise/registrations#update
#                                                     DELETE   /users(.:format)                                                                                  devise/registrations#destroy
#                                                     POST     /users(.:format)                                                                                  devise/registrations#create
#                                     new_user_unlock GET      /users/unlock/new(.:format)                                                                       devise/unlocks#new
#                                         user_unlock GET      /users/unlock(.:format)                                                                           devise/unlocks#show
#                                                     POST     /users/unlock(.:format)                                                                           devise/unlocks#create
#                                         sso_failure GET      /sso_failure(.:format)                                                                            redirect(301, sso_failure.html)
#                          sfdc_scheduler_iframe_demo GET      /sfdc_scheduler_iframe_demo(.:format)                                                             sfdc_external#scheduler_entrypoint
#                                       users_invites GET      /users/invites(.:format)                                                                          users/invites#show
#                                                     PATCH    /users/invites(.:format)                                                                          users/invites#update
#                                                     PUT      /users/invites(.:format)                                                                          users/invites#update
#                                          admin_tags GET      /admin/tags(.:format)                                                                             admin/tags#index
#                                                     POST     /admin/tags(.:format)                                                                             admin/tags#create
#                                       new_admin_tag GET      /admin/tags/new(.:format)                                                                         admin/tags#new
#                                      edit_admin_tag GET      /admin/tags/:id/edit(.:format)                                                                    admin/tags#edit
#                                           admin_tag GET      /admin/tags/:id(.:format)                                                                         admin/tags#show
#                                                     PATCH    /admin/tags/:id(.:format)                                                                         admin/tags#update
#                                                     PUT      /admin/tags/:id(.:format)                                                                         admin/tags#update
#                                                     DELETE   /admin/tags/:id(.:format)                                                                         admin/tags#destroy
#                                        admin_visits GET      /admin/visits(.:format)                                                                           admin/appointments#visit_index {:local_view=>"list"}
#                               admin_visits_calendar GET      /admin/visits/calendar(.:format)                                                                  admin/appointments#visit_index {:local_view=>"calendar"}
#                                    admin_visits_map GET      /admin/visits/map(.:format)                                                                       admin/appointments#index_two {:local_view=>"map"}
#                        admin_background_job_results GET      /admin/background_job_results(.:format)                                                           admin/background_job_results#index
#                     admin_patients_worklist_polling GET      /admin/polling/patients_worklist/:type(.:format)                                                  admin/polling#patients_worklist
#                         admin_kustomer_patients_new GET      /admin/kustomer/patients/new(.:format)                                                            admin/kustomer#new_patients
#                      admin_kustomer_patients_create POST     /admin/kustomer/patients/create(.:format)                                                         admin/kustomer#create_patients
#                              admin_alayacare_create POST     /admin/alayacare/create(.:format)                                                                 admin/alayacare#create_visit
#                     admin_alayacare_field_providers GET      /admin/alayacare/field_providers(.:format)                                                        admin/alayacare#field_providers
#                                                     POST     /admin/visits(.:format)                                                                           admin/patients#visit_notes
#                         admin_capacity_availability GET      /admin/capacity/availability(.:format)                                                            admin/capacity#availability
#             admin_capacity_get_availability_by_date GET      /admin/capacity/get_availability_by_date(.:format)                                                admin/capacity#get_availability_by_date
#              admin_alayacare_patient_visits_partial GET      /admin/alayacare/patient_visits_partial(.:format)                                                 admin/alayacare#patient_visits_partial
#                admin_alayacare_cancel_visit_partial GET      /admin/alayacare/cancel_visit_partial(.:format)                                                   admin/alayacare#cancel_visit_partial
#                        admin_alayacare_cancel_visit POST     /admin/alayacare/cancel_visit(.:format)                                                           admin/alayacare#cancel_visit
#                          admin_alayacare_edit_visit PUT      /admin/alayacare/edit_visit(.:format)                                                             admin/alayacare#edit_visit
#                      admin_alayacare_incoming_event POST     /admin/alayacare/incoming_event(.:format)                                                         admin/alayacare#incoming_event
#                      edit_partial_admin_appointment GET      /admin/appointments/:id/edit_partial(.:format)                                                    admin/appointments#edit_partial
#                       admin_notes_admin_appointment POST     /admin/appointments/:id/admin_notes(.:format)                                                     admin/appointments#admin_notes
#                              tags_admin_appointment POST     /admin/appointments/:id/tags(.:format)                                                            admin/appointments#tags
#            fetch_clinical_summary_admin_appointment POST     /admin/appointments/:id/fetch_clinical_summary(.:format)                                          admin/appointments#fetch_clinical_summary
#                          send_pdf_admin_appointment POST     /admin/appointments/:id/send_pdf(.:format)                                                        admin/appointments#send_pdf
#                     visit_results_admin_appointment POST     /admin/appointments/:id/visit_results(.:format)                                                   admin/appointments#visit_results
#          render_visit_summary_pdf_admin_appointment GET      /admin/appointments/:id/render_visit_summary_pdf(.:format)                                        admin/appointments#render_visit_summary_pdf
#                                  admin_appointments GET      /admin/appointments(.:format)                                                                     admin/appointments#index
#                                                     POST     /admin/appointments(.:format)                                                                     admin/appointments#create
#                               new_admin_appointment GET      /admin/appointments/new(.:format)                                                                 admin/appointments#new
#                              edit_admin_appointment GET      /admin/appointments/:id/edit(.:format)                                                            admin/appointments#edit
#                                   admin_appointment GET      /admin/appointments/:id(.:format)                                                                 admin/appointments#show
#                                                     PATCH    /admin/appointments/:id(.:format)                                                                 admin/appointments#update
#                                                     PUT      /admin/appointments/:id(.:format)                                                                 admin/appointments#update
#                           admin_notes_admin_patient POST     /admin/patients/:id/admin_notes(.:format)                                                         admin/patients#admin_notes
#                               history_admin_patient GET      /admin/patients/:id/history(.:format)                                                             admin/patients#history
#                         update_status_admin_patient PUT      /admin/patients/:id/update_status(.:format)                                                       admin/patients#update_status
#                       alayacare_visit_admin_patient GET      /admin/patients/:id/alayacare_visit(.:format)                                                     admin/patients#alayacare_visit
#                fetch_suggested_visits_admin_patient GET      /admin/patients/:id/fetch_suggested_visits(.:format)                                              admin/patients#fetch_suggested_visits
#                admin_patient_fetch_visit_param_info GET      /admin/patients/:patient_id/fetch_visit_param_info(.:format)                                      admin/patients#fetch_visit_param_info
#                    edit_visit_partial_admin_patient GET      /admin/patients/:id/edit_visit_partial(.:format)                                                  admin/patients#edit_visit_partial
#                           visit_types_admin_patient GET      /admin/patients/:id/visit_types(.:format)                                                         admin/patients#visit_types
#                                admin_patient_visits GET      /admin/patients/:patient_id/visits(.:format)                                                      admin/visits#index
#                                      admin_patients GET      /admin/patients(.:format)                                                                         admin/patients#index
#                                                     POST     /admin/patients(.:format)                                                                         admin/patients#create
#                                   new_admin_patient GET      /admin/patients/new(.:format)                                                                     admin/patients#new
#                                  edit_admin_patient GET      /admin/patients/:id/edit(.:format)                                                                admin/patients#edit
#                                       admin_patient GET      /admin/patients/:id(.:format)                                                                     admin/patients#show
#                                                     PATCH    /admin/patients/:id(.:format)                                                                     admin/patients#update
#                                                     PUT      /admin/patients/:id(.:format)                                                                     admin/patients#update
#                        invite_users_admin_field_org POST     /admin/field_orgs/:id/invite_users(.:format)                                                      admin/field_orgs#invite_users
#                                    admin_field_orgs GET      /admin/field_orgs(.:format)                                                                       admin/field_orgs#index
#                                     admin_field_org GET      /admin/field_orgs/:id(.:format)                                                                   admin/field_orgs#show
#                               admin_demand_partners GET      /admin/demand_partners(.:format)                                                                  admin/demand_partners#index
#                                admin_demand_partner GET      /admin/demand_partners/:id(.:format)                                                              admin/demand_partners#show
#                             edit_partial_admin_user GET      /admin/users/:id/edit_partial(.:format)                                                           admin/users#edit_partial
#                                 invited_admin_users GET      /admin/users/invited(.:format)                                                                    admin/users#index {:show_invited=>true}
#                            resend_invite_admin_user POST     /admin/users/:id/resend_invite(.:format)                                                          admin/users#resend_invite
#                                         admin_users GET      /admin/users(.:format)                                                                            admin/users#index
#                                                     POST     /admin/users(.:format)                                                                            admin/users#create
#                                          admin_user GET      /admin/users/:id(.:format)                                                                        admin/users#show
#                                                     PATCH    /admin/users/:id(.:format)                                                                        admin/users#update
#                                                     PUT      /admin/users/:id(.:format)                                                                        admin/users#update
#                            import_admin_field_users GET      /admin/field_users/import(.:format)                                                               admin/field_users#import
#                    preview_import_admin_field_users POST     /admin/field_users/preview_import(.:format)                                                       admin/field_users#preview_import
#                     submit_import_admin_field_users POST     /admin/field_users/submit_import(.:format)                                                        admin/field_users#submit_import
#                                   admin_hra_surveys GET      /admin/hra_surveys(.:format)                                                                      admin/hra_surveys#index
#                             admin_patient_prospects GET      /admin/patient_prospects(.:format)                                                                admin/patient_prospects#index
#                              admin_patient_prospect GET      /admin/patient_prospects/:id(.:format)                                                            admin/patient_prospects#show
#                                                     DELETE   /admin/patient_prospects/:id(.:format)                                                            admin/patient_prospects#destroy
#                                         admin_visit PATCH    /admin/visits/:id(.:format)                                                                       admin/visits#update
#                                                     PUT      /admin/visits/:id(.:format)                                                                       admin/visits#update
#                    send_one_admin_outreach_campaign POST     /admin/outreach_campaigns/:id/send_one(.:format)                                                  admin/outreach_campaigns#send_one
#                            admin_outreach_campaigns GET      /admin/outreach_campaigns(.:format)                                                               admin/outreach_campaigns#index
#                                          admin_root GET      /admin(.:format)                                                                                  admin/patients#index
#                                          field_root GET      /field(.:format)                                                                                  field/patients#index
#                                        field_visits GET      /field/visits(.:format)                                                                           field#visits
#                                  field_cancel_visit POST     /field/cancel_visit(.:format)                                                                     field/visits#cancel_visit
#                          field_cancel_visit_partial GET      /field/cancel_visit_partial(.:format)                                                             field/visits#cancel_visit_partial
#                                         field_visit PATCH    /field/visits/:id(.:format)                                                                       field/visits#update
#                                                     PUT      /field/visits/:id(.:format)                                                                       field/visits#update
#                       field_appointment_hra_surveys POST     /field/appointments/:appointment_id/hra_surveys(.:format)                                         field/hra_surveys#create
#                    new_field_appointment_hra_survey GET      /field/appointments/:appointment_id/hra_surveys/new(.:format)                                     field/hra_surveys#new
#                    respond_field_appointment_survey POST     /field/appointments/:appointment_id/surveys/:id/respond(.:format)                                 field/surveys#respond
#                            field_appointment_survey GET      /field/appointments/:appointment_id/surveys/:id(.:format)                                         field/surveys#show
#      edit_field_appointment_extra_vaccine_recipient GET      /field/appointments/:appointment_id/extra_vaccine_recipients/:id/edit(.:format)                   field/extra_vaccine_recipients#edit
#           field_appointment_extra_vaccine_recipient PATCH    /field/appointments/:appointment_id/extra_vaccine_recipients/:id(.:format)                        field/extra_vaccine_recipients#update
#                                                     PUT      /field/appointments/:appointment_id/extra_vaccine_recipients/:id(.:format)                        field/extra_vaccine_recipients#update
#                                  field_appointments GET      /field/appointments(.:format)                                                                     field/appointments#index
#                                   field_appointment GET      /field/appointments/:id(.:format)                                                                 field/appointments#show
#                                                     PATCH    /field/appointments/:id(.:format)                                                                 field/appointments#update
#                                                     PUT      /field/appointments/:id(.:format)                                                                 field/appointments#update
#                           admin_notes_field_patient POST     /field/patients/:id/admin_notes(.:format)                                                         field/patients#admin_notes
#                               history_field_patient GET      /field/patients/:id/history(.:format)                                                             field/patients#history
#                         update_status_field_patient PUT      /field/patients/:id/update_status(.:format)                                                       field/patients#update_status
#                       alayacare_visit_field_patient GET      /field/patients/:id/alayacare_visit(.:format)                                                     field/patients#alayacare_visit
#                fetch_suggested_visits_field_patient GET      /field/patients/:id/fetch_suggested_visits(.:format)                                              field/patients#fetch_suggested_visits
#                field_patient_fetch_visit_param_info GET      /field/patients/:patient_id/fetch_visit_param_info(.:format)                                      field/patients#fetch_visit_param_info
#                    edit_visit_partial_field_patient GET      /field/patients/:id/edit_visit_partial(.:format)                                                  field/patients#edit_visit_partial
#                           visit_types_field_patient GET      /field/patients/:id/visit_types(.:format)                                                         field/patients#visit_types
#                                field_patient_visits GET      /field/patients/:patient_id/visits(.:format)                                                      field/visits#index
#                                      field_patients GET      /field/patients(.:format)                                                                         field/patients#index
#                                                     POST     /field/patients(.:format)                                                                         field/patients#create
#                                   new_field_patient GET      /field/patients/new(.:format)                                                                     field/patients#new
#                                  edit_field_patient GET      /field/patients/:id/edit(.:format)                                                                field/patients#edit
#                                       field_patient GET      /field/patients/:id(.:format)                                                                     field/patients#show
#                                                     PATCH    /field/patients/:id(.:format)                                                                     field/patients#update
#                                                     PUT      /field/patients/:id(.:format)                                                                     field/patients#update
#                         field_capacity_availability GET      /field/capacity/availability(.:format)                                                            field/capacity#availability
#             field_capacity_get_availability_by_date GET      /field/capacity/get_availability_by_date(.:format)                                                field/capacity#get_availability_by_date
#                          dashboard_field_admin_root GET      /dashboard/field_admin(.:format)                                                                  redirect(301, /dashboard/field_admin/users/office_users)
#            office_users_dashboard_field_admin_users GET      /dashboard/field_admin/users/office_users(.:format)                                               dashboard/field_admin/users#office_users
#         field_providers_dashboard_field_admin_users GET      /dashboard/field_admin/users/field_providers(.:format)                                            dashboard/field_admin/users#field_providers
#            resend_invite_dashboard_field_admin_user POST     /dashboard/field_admin/users/:id/resend_invite(.:format)                                          dashboard/field_admin/users#resend_invite
#                         dashboard_field_admin_users GET      /dashboard/field_admin/users(.:format)                                                            dashboard/field_admin/users#index
#                                                     POST     /dashboard/field_admin/users(.:format)                                                            dashboard/field_admin/users#create
#                      new_dashboard_field_admin_user GET      /dashboard/field_admin/users/new(.:format)                                                        dashboard/field_admin/users#new
#                         data_import_new_data_import GET      /data_import/new_data_import(.:format)                                                            data_import#new_data_import
#                             data_import_data_import POST     /data_import/data_import(.:format)                                                                data_import#data_import
#                             visit_routing_new_visit GET      /visit_routing/new_visit(.:format)                                                                visit_routing#new_visit
#                           visit_routing_get_options POST     /visit_routing/get_options(.:format)                                                              visit_routing#get_options
#                       alayacare_control_panel_index GET      /alayacare_control_panel/index(.:format)                                                          alayacare_control_panel#index
#     alayacare_control_panel_sync_demand_partner_ids POST     /alayacare_control_panel/sync_demand_partner_ids(.:format)                                        alayacare_control_panel#sync_demand_partner_ids
#        alayacare_control_panel_sync_cancel_code_ids POST     /alayacare_control_panel/sync_cancel_code_ids(.:format)                                           alayacare_control_panel#sync_cancel_code_ids
#            alayacare_control_panel_sync_service_ids POST     /alayacare_control_panel/sync_service_ids(.:format)                                               alayacare_control_panel#sync_service_ids
#                  alayacare_control_panel_dedup_mrns POST     /alayacare_control_panel/dedup_mrns(.:format)                                                     alayacare_control_panel#dedup_mrns
#    alayacare_control_panel_backfill_field_providers POST     /alayacare_control_panel/backfill_field_providers(.:format)                                       alayacare_control_panel#backfill_field_providers
#            alayacare_control_panel_sync_visit_types POST     /alayacare_control_panel/sync_visit_types(.:format)                                               alayacare_control_panel#sync_visit_types
#                alayacare_control_panel_clear_caches POST     /alayacare_control_panel/clear_caches(.:format)                                                   alayacare_control_panel#clear_caches
#             alayacare_control_panel_backfill_visits POST     /alayacare_control_panel/backfill_visits(.:format)                                                alayacare_control_panel#backfill_visits
#                          athena_control_panel_index GET      /athena_control_panel/index(.:format)                                                             athena_control_panel#index
#            athena_control_panel_sync_department_ids POST     /athena_control_panel/sync_department_ids(.:format)                                               athena_control_panel#sync_department_ids
#           athena_control_panel_sync_cancel_code_ids POST     /athena_control_panel/sync_cancel_code_ids(.:format)                                              athena_control_panel#sync_cancel_code_ids
#               athena_control_panel_sync_service_ids POST     /athena_control_panel/sync_service_ids(.:format)                                                  athena_control_panel#sync_service_ids
#            athena_control_panel_sync_visit_type_ids POST     /athena_control_panel/sync_visit_type_ids(.:format)                                               athena_control_panel#sync_visit_type_ids
#          athena_control_panel_sync_custom_field_ids POST     /athena_control_panel/sync_custom_field_ids(.:format)                                             athena_control_panel#sync_custom_field_ids
#        athena_control_panel_sync_field_provider_ids POST     /athena_control_panel/sync_field_provider_ids(.:format)                                           athena_control_panel#sync_field_provider_ids
# athena_control_panel_initialize_regression_fixtures POST     /athena_control_panel/initialize_regression_fixtures(.:format)                                    athena_control_panel#initialize_regression_fixtures
#                                                     GET      /papertrail/:type/:id(.:format)                                                                   papertrail#show_history
#                                                root GET      /                                                                                                 application#redirect_to_home_page
#                        ruby_event_store_browser_app          /res                                                                                              RubyEventStore::Browser::App
#                                             flipper          /flipper                                                                                          Flipper::UI
#                                         delayed_job GET|POST /delayed_job(.:format)                                                                            DelayedJobWeb
#                                              health GET      /health(.:format)                                                                                 application#health_check
#                               jwt_web_scheduler_new GET      /jwt_web/scheduler/new(.:format)                                                                  jwt_web/scheduler#new
#                        jwt_web_scheduler_reschedule GET      /jwt_web/scheduler/reschedule(.:format)                                                           jwt_web/scheduler#reschedule
#                                       api_v1_visits GET      /api/v1/visits(.:format)                                                                          api/v1/visits#index
#                                                     POST     /api/v1/visits(.:format)                                                                          api/v1/visits#create
#                                    new_api_v1_visit GET      /api/v1/visits/new(.:format)                                                                      api/v1/visits#new
#                                   edit_api_v1_visit GET      /api/v1/visits/:id/edit(.:format)                                                                 api/v1/visits#edit
#                                        api_v1_visit GET      /api/v1/visits/:id(.:format)                                                                      api/v1/visits#show
#                                                     PATCH    /api/v1/visits/:id(.:format)                                                                      api/v1/visits#update
#                                                     PUT      /api/v1/visits/:id(.:format)                                                                      api/v1/visits#update
#                                                     DELETE   /api/v1/visits/:id(.:format)                                                                      api/v1/visits#destroy
#                                  api_v1_visit_event POST     /api/v1/visit_event(.:format)                                                                     api/v1/visit_event#create
#                                                     GET      /api/v1/visit_event(.:format)                                                                     api/v1/visit_event#show
#                                 inbound_lambdaforce POST     /inbound/lambdaforce(.:format)                                                                    lambdaforce#inbound
#                                 lambdaforce_inbound POST     /lambdaforce/inbound(.:format)                                                                    lambdaforce#inbound
#                                                     POST     /lambdaforce/emit/:ma_id(.:format)                                                                lambdaforce#emit
#                       rails_postmark_inbound_emails POST     /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#                          rails_relay_inbound_emails POST     /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#                       rails_sendgrid_inbound_emails POST     /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#                 rails_mandrill_inbound_health_check GET      /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#                       rails_mandrill_inbound_emails POST     /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#                        rails_mailgun_inbound_emails POST     /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#                      rails_conductor_inbound_emails GET      /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                                     POST     /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#                   new_rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#                  edit_rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/:id/edit(.:format)                                 rails/conductor/action_mailbox/inbound_emails#edit
#                       rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
#                                                     PATCH    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
#                                                     PUT      /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
#                                                     DELETE   /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#destroy
#            new_rails_conductor_inbound_email_source GET      /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#               rails_conductor_inbound_email_sources POST     /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#               rails_conductor_inbound_email_reroute POST     /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
#                                  rails_service_blob GET      /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                            rails_service_blob_proxy GET      /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                                     GET      /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                           rails_blob_representation GET      /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#                     rails_blob_representation_proxy GET      /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                                     GET      /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                                  rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                           update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                                rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for GraphiQL::Rails::Engine:
#        GET  /           graphiql/rails/editors#show
#
# Routes for RailsAdmin::Engine:
#   dashboard GET        /                                      rails_admin/main#dashboard
#       index GET|POST   /:model_name(.:format)                 rails_admin/main#index
#         new GET|POST   /:model_name/new(.:format)             rails_admin/main#new
#      export GET|POST   /:model_name/export(.:format)          rails_admin/main#export
# bulk_action POST       /:model_name/bulk_action(.:format)     rails_admin/main#bulk_action
#        show GET        /:model_name/:id(.:format)             rails_admin/main#show
#        edit GET|PUT    /:model_name/:id/edit(.:format)        rails_admin/main#edit
# show_in_app GET        /:model_name/:id/show_in_app(.:format) rails_admin/main#show_in_app
#      delete GET|DELETE /:model_name/:id/delete(.:format)      rails_admin/main#delete
