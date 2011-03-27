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

  def find_or_create_workflow workflow_name
    # look it up an instance in the DB based on caller()
  end

  def step_workflow
  end

  def delete
  end

  def input
    find_or_create_workflow params[:id]
    step_workflow
    respond_to do |fmt|
      fmt.json { 
        render :json => {
          :workflow_name  => params[:id],
          :workflow_state => '*none*',
          :twml           => '*none*'
        }
      }
      fmt.any { render :content_type => 'text/xml', :text => <<-END
<!-- Workflow Name:  #{params[:id]} -->
<!-- Workflow State: ... -->
<twml>
...TWML should be here...
</twml>
      END
      }
    end
  end

end
