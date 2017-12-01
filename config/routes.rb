class MobileConstraint
  def self.matches?(request)
    (request.user_agent.to_s =~ /Mobile|webOS/) or request.subdomain.start_with?('m')
  end
end

Rails.application.routes.draw do
  get 'robots', to: 'application#robots', format: :txt

  mount RedactorRails::Engine => '/redactor_rails'
  mount RuCaptcha::Engine => '/rucaptcha'

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  namespace :onecmsmanage, module: :admin, as: :admin do
    get :login, to: 'sessions#new'
    post :login, to: 'sessions#create'
    resources :articles do
      collection do
        get :search
      end
    end

    resources :nodes do
      collection do
        get :list
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

    resources :users
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
      resources :tags,  only: [:index, :show],    trailing_slash: true
      get 'z',            to: 'channels#index',   as: :channels, trailing_slash: true
      get 'z/:slug',      to: 'channels#show',    as: :channel, trailing_slash: true
      get ':slug/:id',    to: 'articles#show'
      get ':slug',        to: 'articles#index',   as: :articles, trailing_slash: true
    end
  end 
  
  scope module: :site do
    root 'application#index'
    get 'more',         to: 'application#more'

    match 'sign_up',    to: 'welcome#sign_up', as: :sign_up,   via: [:get, :post]
    match 'sign_in',    to: 'welcome#sign_in', as: :sign_in,   via: [:get, :post]
    match 'sign_out',   to: 'welcome#sign_out', as: :sign_out, via: [:delete]
    match 'profile',    to: 'welcome#profile', as: :profile,   via: [:get, :post]
    match 'password',    to: 'welcome#password', as: :password,   via: [:get, :post]
    get 'check_login',  to: 'welcome#check_login', as: :check_login
    get 'active/:token', to: 'welcome#activation', as: :active_user

    resources :comments
    resources :tags,  only: [:index, :show],    trailing_slash: true
    get 'feed',         to: 'articles#feed',    as: :feed
    get 'search',       to: 'articles#search',  as: :search
    get 'z',            to: 'channels#index',   as: :channels, trailing_slash: true
    get 'z/:slug',      to: 'channels#show',    as: :channel, trailing_slash: true
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
