require "net/http"
class Api::PostsController < ApplicationController
    before_action :assert_params
    def show
        posts = nil
        sort_by = "id"
        order_by = "asc"
        posts, response = api_request()
        if posts.instance_of?(Hash) && ( response.kind_of?(Net::HTTPOK) && response.code == "200")
            
            if post_params.has_key?(:sortBy)
                if posts["posts"].first.keys.include?(post_params[:sortBy]) && post_params[:sortBy] != "tags"
                    sort_by = post_params[:sortBy]
                else
                    return render json: {error: "sortBy parameter is invalid"}, status: :bad_request
                end
            end
            
            if post_params.has_key? :direction
                if ["asc", "desc"].include?(post_params[:direction])
                    order_by == post_params[:direction]
                else
                    return render json: {error: "direction parameter is invalid"}
                end
            end
            posts = filtered_posts(posts, post_params[:sortBy], post_params[:direction] ||="asc")
            render json: posts, status: :ok
        else
            render json: {Error: response.message}, status: :unprocessable_entity
        end
    end

    def ping
        render json: {success: true}, status: :ok
    end

    private
    def post_params
        params.permit(:tags, :sortBy, :direction, :tech)
    end

    def params_to_query
        post_params.to_h.to_query
    end
    
    def assert_params
        return render json: {error: "Tags parameter is required"}, status: :bad_request unless post_params.has_key? :tags
    end

    def api_request
        data = nil
        response = nil
        begin
            uri = URI("https://api.hatchways.io/assessment/solution/posts?")
            uri.query = URI.encode_www_form({tags: post_params[:tags]})
            response = Net::HTTP.get_response(uri)
            data = JSON.parse(response.body)
        rescue => exception
            response = exception
        end
        return data, response
    end

    def filtered_posts(posts, sort_by, order_by)
        filtered = nil
        if order_by == "asc"
            filtered = posts["posts"].sort_by{ |key, value| key[sort_by] }
        else
            filtered = posts["posts"].sort_by{ |key, value| key[sort_by] }.reverse
        end
        filtered
    end

end
