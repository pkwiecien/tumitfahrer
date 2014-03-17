class Api::V1::ProjectsController < ApiController
  respond_to :xml, :json
  before_filter :load_parent

  def index
    if params.has_key?(:user_id)
      # mapping for url : /api/version/users/1/projects
      @projects = @parent.projects.all
    else
      # mapping for url: /api/version/projects
      @projects = Project.all
    end

    respond_to do |format|
      format.json { render json: @projects, :each_serializer => ProjectSerializer }
      format.xml { render xml: @projects }
    end
  end

  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.json { render json: @project }
      format.xml { render xml: @project }
    end
  end

  def create
    user = User.find_by(id: params[:user_id])
    project = user.projects.create!(title: params[:title], owner_id: user.id, description: params[:description],
                         fundings_target: params[:fundings_target])
    unless project.nil?
      respond_to do |format|
        format.json { render json: project }
        format.xml { render xml: project }
      end
    else
      render json: {:result => "0"}
    end


  end

  private

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

end
