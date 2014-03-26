class Api::V1::ProjectsController < ApiController
  respond_to :xml, :json
  before_filter :load_parent

  # GET /api/v1/projects or GET /api/v1/users/:user_id/projects
  def index
    if params.has_key?(:offered)
      # mapping for url : /api/version/users/1/projects
      @projects = @parent.offered_projects.all
    elsif params.has_key?(:contributed)
      @projects = @parent.contributed_projects
    else
      @projects = Project.all
    end

    respond_with @projects, :each_serializer => ProjectSerializer, status: :ok
  end

  # GET /api/v1/projects/:id
  def show
    project = Project.find_by(id: params[:id])
    if project.nil?
      respond_with project, status: :not_found
    else
      respond_with project, status: :ok
    end
  end

  # POST /api/v1/users/:user_id/projects
  def create
    user = User.find_by(id: params[:user_id])
    return :project => {}, status: :not_found if user.nil?

    project = user.offered_projects.create!(title: params[:title], owner_id: user.id, description: params[:description],
                                            fundings_target: params[:fundings_target])
    unless project.nil?
      respond_with project, status: :created
    else
      respond_with project, status: :bad_request
    end
  end

  # PUT /api/v1/projects/:id
  def update
    project = Project.find_by(id: params[:id])

    if project.nil?
      respond_with project, status: :not_found
    end

    project.update_attributes(project_params)
    respond_with project, status: :ok
  end

  private

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

  def project_params
    params.require("project").permit(:title, :description, :phase)
  end

end
