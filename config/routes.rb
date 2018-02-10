class MobileConstraint
  def self.matches?(request)
    (request.user_agent.to_s =~ /Mobile|webOS/) or request.subdomain.start_with?('m')
  end
end

Rails.application.routes.draw do
  get 'robots', to: 'application#robots', format: :txt
  get 'dasai', to: 'application#dasai'

  mount RedactorRails::Engine => '/redactor_rails'
  mount RuCaptcha::Engine => '/rucaptcha'

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  scope path: '/api/v1', module: 'api/v1', as: :api_v1 do
    get "/category/:category_id/page/:page", to: 'articles#index', defaults: { format: :json }

    resources :categories
    resources :articles, only: [:index]
  end

  namespace :onecmsmanage, module: :admin, as: :admin do
    get :login, to: 'sessions#new'
    post :login, to: 'sessions#create'
    
    resources :articles do
      collection do
        get :search
        get :unapproved
      end
    end

    resources :comments

    resources :nodes do
      collection do
        get :list
      end

      member do
        post :clear_cache
      end
    end

    resources :keywords
    resources :links, except: :show
    resources :channels
    resources :site_ads
    resources :hot_articles
    get 'site_config',  to: 'site_config#edit',     as: :site_config
    post 'site_config', to: 'site_config#update',  as: :site_configs

    scope :cache, controller: 'cache', as: :cache do
      get '/', to: 'cache#index'
      post 'refresh', to: 'cache#refresh', as: :refresh
      post :refresh_all
      post :precompile
      post :restart
    end

    resources :users do
      collection do
        get :search
      end
    end

    resources :tokens

    get :mip, to: 'site_config#mip', as: :mip
  end

  get 'sitemap/:node_id-:page', to: 'sitemap#show', constraints: { format: 'xml' }
  get 'mipmap/:node_id-:page', to: 'sitemap#mipmap', constraints: { format: 'xml' }
  # get 'mipmap',       to: 'sitemap#mipmap', constraints: { format: 'xml' }
  get 'mip',          to: 'mobile/mip#index',        as: :mip, trailing_slash: true
  get 'mip/:slug',    to: 'mobile/mip#node',         as: :mip_node, trailing_slash: true
  get 'mip/:slug/:id',to: 'mobile/mip#show'

  constraints(MobileConstraint) do
    scope module: 'mobile', as: :mobile do
      root 'application#index'

      match 'sign_up_mobile',    to: 'application#sign_up_mobile', as: :sign_up_mobile,   via: [:get, :post]
      match 'send_active_code',    to: 'application#send_active_code', as: :send_active_code,   via: [:post]
      match 'send_email_code',    to: 'application#send_email_code', as: :send_email_code,   via: [:post]
      match 'sign_in',    to: 'application#sign_in', as: :sign_in,   via: [:get, :post]
      match 'sign_out',   to: 'application#sign_out', as: :sign_out, via: [:delete]
      get 'check_login',  to: 'application#check_login', as: :check_login
      get 'column',  to: 'application#column', as: :column, trailing_slash: true

      resources :comments do
        collection do
          get :user_comments
        end
      end

      resources :tags,  only: [:index, :show],    trailing_slash: true
      get 'z',            to: 'channels#index',   as: :channels, trailing_slash: true
      get 'z/:slug',      to: 'channels#show',    as: :channel, trailing_slash: true
      get 'articles',     to: 'articles#user_articles',  as: :user_articles
      get ':slug/:id',    to: 'articles#show'
      get ':slug',        to: 'articles#index',   as: :articles, trailing_slash: true
    end
  end 
  
  scope module: :site do
    root 'application#site_index'
    get 'more',         to: 'application#more'

    match 'sign_up',    to: 'welcome#sign_up', as: :sign_up,   via: [:get, :post]
    match 'sign_up_mobile',    to: 'welcome#sign_up_mobile', as: :sign_up_mobile,   via: [:get, :post]
    match 'send_active_code',    to: 'welcome#send_active_code', as: :send_active_code,   via: [:post]
    match 'send_email_code',    to: 'welcome#send_email_code', as: :send_email_code,   via: [:post]
    match 'sign_in',    to: 'welcome#sign_in', as: :sign_in,   via: [:get, :post]
    match 'sign_out',   to: 'welcome#sign_out', as: :sign_out, via: [:delete]
    match 'profile',    to: 'welcome#profile', as: :profile,   via: [:get, :post]
    match 'password',    to: 'welcome#password', as: :password,   via: [:get, :post]
    get 'check_login',  to: 'welcome#check_login', as: :check_login
    get 'active/:token', to: 'welcome#activation', as: :active_user
    get 'users/rank', to: 'welcome#users_rank', as: :users_rank

    get 'column',  to: 'application#column', as: :column, trailing_slash: true
    
    resources :comments do
      collection do
        get :read_counts
      end
    end

    resources :hongbaos, only: [:index, :create] do
      collection do
        post :open
        get :tokens
        get :withdraws
        match 'tokens/withdraw', to: 'hongbaos#new_withdraw', as: :new_withdraw, via: [:get, :post]
      end
    end

    resources :tags,  only: [:index, :show],    trailing_slash: true
    get 'feed',         to: 'articles#feed',    as: :feed
    get 'search',       to: 'articles#search',  as: :search
    get 'z',            to: 'channels#index',   as: :channels, trailing_slash: true
    get 'z/:slug',      to: 'channels#show',    as: :channel, trailing_slash: true
    get 'fetch_articles/:slug',        to: 'articles#fetch_articles'
    get 'articles/new', to: 'articles#new',     as: :new_article
    get 'articles',     to: 'articles#user_articles',  as: :user_articles
    post 'articles',    to: 'articles#create',  as: :create_article
    get 'articles/:id/edit',     to: 'articles#edit',  as: :edit_article
    put 'articles/:id',     to: 'articles#update',  as: :update_article
    delete 'articles/:id',     to: 'articles#destroy',  as: :delete_article
    get ':slug/:id',    to: 'articles#show',    as: :article
    get ':slug',        to: 'articles#index',   as: :articles, trailing_slash: true
  end
end
