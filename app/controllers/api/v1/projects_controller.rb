class Api::V1::ProjectsController < ApiController
  respond_to :xml, :json
  before_filter :load_parent

  def index

    if params.has_key?(:offered)
      # mapping for url : /api/version/users/1/projects
      @projects = @parent.offered_projects.all
    elsif params.has_key?(:contributed)
      @projects = @parent.contributed_projects
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
    project = Project.find_by(id: params[:id])
    if project.nil?
      respond_to do |format|
        format.json { render json: {:status => 400} }
        format.xml { render xml: {:status => 400} }
      end
    else
      respond_to do |format|
        format.json { render json: project }
        format.xml { render xml: project }
      end
    end
  end

  def create
    user = User.find_by(id: params[:user_id])
    project = user.offered_projects.create!(title: params[:title], owner_id: user.id, description: params[:description],
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

  def update
    project = Project.find_by(id: params[:id])

    if project.nil?
      render json: {:status => 400}
    end

    project.update_attributes(project_params)
    render json: {:status => 200}
  end

  private

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

  def project_params
    params.require("project").permit(:title, :description, :phase)
  end

end
