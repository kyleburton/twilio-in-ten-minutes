class WorkflowController < ApplicationController
  layout 'site'

  before_filter :expire_old_sessions, :only => [:show, :input]

  def show
    name = params[:id]
    find_or_create_session name
    @graph_png = "/workflows/#{name.downcase}.png"
    if !File.exist?("#{RAILS_ROOT}/public#{@graph_png}")
      flash[:error] = "You need to run 'rake ivr:render_workflows' in your app to generate the workflow graphs."
    end
  end

  def input
    find_or_create_session params[:id]
    step_workflow
    twml = <<-END
#{@workflow.message}
<!-- Workflow Name:  #{params[:id]} -->
<!-- Workflow State: #{@workflow.current_state} -->
    END
    respond_to do |fmt|
      fmt.xml { render :content_type => 'text/xml', :text => twml }
      fmt.json { 
        render :json => {
          :workflow_name  => @call_session.workflow_name,
          :workflow_state => @call_session.state,
          :error          => @error,
          :finished       => @workflow.workflow.states[@workflow.workflow.current_state].stop?,
          :twml           => twml
        }
      }
    end
  end

end
