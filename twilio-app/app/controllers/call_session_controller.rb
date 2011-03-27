class CallSessionController < ApplicationController
  def delete
    Rails.logger.info "delete call: #{params[:id]}"
    render :content_type => 'text/json', :json => {
      :status => "deleted",
      :session_id => params[:id],
    }
  end
end
