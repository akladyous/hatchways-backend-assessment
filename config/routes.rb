Rails.application.routes.draw do
    Rails.application.routes.draw do
        namespace :api do
            get "posts", to: "posts#show"
            get "ping", to: "posts#ping"
        end
    end
end
