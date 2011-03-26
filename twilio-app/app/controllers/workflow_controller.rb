class WorkflowController < ApplicationController
  layout 'site'

  def show
    name = params[:id]
    @workflow = Ivrflow.new_workflow name
    @graph_png = "/workflows/#{name.downcase}.png"
    if !File.exist?("#{RAILS_ROOT}/public#{@graph_png}")
      flash[:error] = "You need to run 'rake ivr:render_workflows' in your app to generate the workflow graphs."
    end
  end
end
