Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  devise_scope :candidate do
    get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
  end

  root to: redirect('/candidate')

  get '/accessibility', to: 'content#accessibility'
  get '/candidate/terms-of-use', to: 'content#terms_candidate', as: :terms_candidate

  namespace :candidate_interface, path: '/candidate' do
    get '/' => 'start_page#show', as: :start

    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'

    get '/apply', to: 'apply_from_find#show', as: :apply_from_find

    scope '/application' do
      get '/' => 'application_form#show', as: :application_form
      get '/review' => 'application_form#review', as: :application_review
      get '/submit' => 'application_form#submit_show', as: :application_submit_show
      post '/submit' => 'application_form#submit', as: :application_submit
      get '/submit-success' => 'application_form#submit_success', as: :application_submit_success

      scope '/personal-details' do
        get '/' => 'personal_details#edit', as: :personal_details_edit
        post '/review' => 'personal_details#update', as: :personal_details_update
        get '/review' => 'personal_details#show', as: :personal_details_show
      end

      scope '/personal-statement' do
        get '/becoming-a-teacher' => 'personal_statement/becoming_a_teacher#edit', as: :becoming_a_teacher_edit
        post '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#update', as: :becoming_a_teacher_update
        get '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#show', as: :becoming_a_teacher_show

        get '/subject-knowledge' => 'personal_statement/subject_knowledge#edit', as: :subject_knowledge_edit
        post '/subject-knowledge/review' => 'personal_statement/subject_knowledge#update', as: :subject_knowledge_update
        get '/subject-knowledge/review' => 'personal_statement/subject_knowledge#show', as: :subject_knowledge_show

        get '/interview-preferences' => 'personal_statement/interview_preferences#edit', as: :interview_preferences_edit
        post '/interview-preferences/review' => 'personal_statement/interview_preferences#update', as: :interview_preferences_update
        get '/interview-preferences/review' => 'personal_statement/interview_preferences#show', as: :interview_preferences_show
      end

      scope '/contact-details' do
        get '/' => 'contact_details/base#edit', as: :contact_details_edit_base
        post '/' => 'contact_details/base#update', as: :contact_details_update_base

        get '/address' => 'contact_details/address#edit', as: :contact_details_edit_address
        post '/address' => 'contact_details/address#update', as: :contact_details_update_address

        get '/review' => 'contact_details/review#show', as: :contact_details_review
      end

      scope '/gcse/:subject' do
        get '/' => 'gcse/type#edit', as: :gcse_details_edit_type
        post '/' => 'gcse/type#update', as: :gcse_details_update_type

        get '/details' => 'gcse/details#edit', as: :gcse_details_edit_details
        patch '/details' => 'gcse/details#update', as: :gcse_details_update_details

        get '/review' => 'gcse/review#show', as: :gcse_review
      end

      scope '/work-history' do
        get '/length' => 'work_history/length#show', as: :work_history_length
        post '/length' => 'work_history/length#submit'

        get '/missing' => 'work_history/explanation#show', as: :work_history_explanation
        post '/missing' => 'work_history/explanation#submit'

        get '/new' => 'work_history/edit#new', as: :work_history_new
        post '/create' => 'work_history/edit#create', as: :work_history_create
        get '/edit/:id' => 'work_history/edit#edit', as: :work_history_edit
        post '/edit/:id' => 'work_history/edit#update'

        get '/review' => 'work_history/review#show', as: :work_history_show
        patch '/review' => 'work_history/review#complete', as: :work_history_complete

        get '/delete/:id' => 'work_history/destroy#confirm_destroy', as: :work_history_destroy
        delete '/delete/:id' => 'work_history/destroy#destroy'
      end

      scope '/degrees' do
        get '/' => 'degrees/base#new', as: :degrees_new_base
        post '/' => 'degrees/base#create', as: :degrees_create_base

        get '/review' => 'degrees/review#show', as: :degrees_review
        patch '/review' => 'degrees/review#complete', as: :degrees_complete

        get '/edit/:id' => 'degrees/base#edit', as: :degrees_edit
        post '/edit/:id' => 'degrees/base#update'

        get '/delete/:id' => 'degrees/destroy#confirm_destroy', as: :confirm_degrees_destroy
        delete '/delete/:id' => 'degrees/destroy#destroy'
      end

      scope '/courses' do
        get '/' => 'course_choices#index', as: :course_choices_index

        get '/choose' => 'course_choices#have_you_chosen', as: :course_choices_choose
        post '/choose' => 'course_choices#make_choice'

        get '/provider' => 'course_choices#options_for_provider', as: :course_choices_provider
        post '/provider' => 'course_choices#pick_provider'

        get '/provider/:provider_code/courses' => 'course_choices#options_for_course', as: :course_choices_course
        post '/provider/:provider_code/courses' => 'course_choices#pick_course'

        get '/provider/:provider_code/courses/:course_code' => 'course_choices#options_for_site', as: :course_choices_site
        post '/provider/:provider_code/courses/:course_code' => 'course_choices#pick_site'
      end

      scope '/other-qualifications' do
        get '/' => 'other_qualifications/base#new', as: :new_other_qualification
        post '/' => 'other_qualifications/base#create', as: :create_other_qualification

        get '/review' => 'other_qualifications/review#show', as: :review_other_qualifications
        patch '/review' => 'other_qualifications/review#complete', as: :complete_other_qualifications

        get '/edit/:id' => 'other_qualifications/base#edit', as: :edit_other_qualification
        post '/edit/:id' => 'other_qualifications/base#update'

        get '/delete/:id' => 'other_qualifications/destroy#confirm_destroy', as: :confirm_destroy_other_qualification
        delete '/delete/:id' => 'other_qualifications/destroy#destroy'
      end
    end
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'

    post '/applications/:application_id/offer' => 'decisions#make_offer'
    post '/applications/:application_id/confirm-conditions-met' => 'decisions#confirm_conditions_met'
    post 'applications/:application_id/reject' => 'decisions#reject'
    post '/applications/:application_id/confirm-enrolment' => 'decisions#confirm_enrolment'

    post '/test-data/regenerate' => 'test_data#regenerate'

    get '/ping', to: 'ping#ping'
  end

  namespace :provider_interface, path: '/provider' do
    get '/' => redirect('/provider/applications')
    get '/sign-out' => 'sessions#sign_out', as: :sign_out
    get '/sign-in' => 'sessions#new', as: :sign_in

    get '/applications' => 'application_choices#index'
    get '/applications/:application_choice_id' => 'application_choices#show', as: :application_choice
  end

  get '/auth/dfe/callback' => 'provider_interface/sessions#callback'

  namespace :support_interface, path: '/support' do
    get '/' => redirect('/support/applications')

    get '/applications' => 'application_forms#index'
    get '/applications/:application_form_id' => 'application_forms#show', as: :application_form
    get '/applications/:application_form_id/audit' => 'application_forms#audit', as: :application_form_audit

    get '/tokens' => 'api_tokens#index', as: :api_tokens
    post '/tokens' => 'api_tokens#create'

    get '/vendors' => 'manage_vendors#index'
    post '/vendors' => 'manage_vendors#create'

    get '/providers' => 'providers#index', as: :providers
    post '/providers/sync' => 'providers#sync'
  end

  get '/check', to: 'healthcheck#show'
  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'
  get '*path', to: 'errors#not_found'
end
