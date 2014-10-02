class PhotosController < ApplicationController
  load_and_authorize_resource

  cache_sweeper :photo_sweeper

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photo = Photo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new
    @type = params[:type]
    @id = params[:id]

    page = params[:page] || 1

    @flickr_auth = current_member.auth('flickr')
    @current_set = params[:set]
    if @flickr_auth
      @sets = current_member.flickr_sets
      photos, total = current_member.flickr_photos(page, @current_set)

      @photos = WillPaginate::Collection.create(page, 30, total) do |pager|
        pager.replace photos
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.find_by_flickr_photo_id(params[:photo][:flickr_photo_id]) ||
      Photo.new(params[:photo])
    @photo.owner_id = current_member.id
    @photo.set_flickr_metadata

    # several models can have photos. we need to know what model and the id
    # for the entry to attach the photo to
    valid_models = ["planting", "harvest"]
    if ! params[:type]
      flash[:alert] = "Missing type parameter"
  	return 1
    end
    if ! valid_models.include?(params[:type])
      flash[:alert] = "Cannot attach photos to #{params[:type]}"
      return 1
    end
    if ! params[:id]
      flash[:alert] = "Missing id parameter"
      return 1
    end
    item = params[:type].camelcase.constantize.find_by_id(params[:id])
    if ! item
      flash[:alert] = "Couldn't find #{params[:type]} to connect to photo."
      return 1
    end
    if item.owner.id != current_member.id
      flash[:alert] = "You must own both the #{params[:type]} and the photo."
      return 1
    end
    #  This syntax is weird, so just know that it means this:
    #  @photo.harvests << item unless @photo.harvests.include?(item)
    #  but with the correct many-to-many relationship automatically referenced
    (@photo.send "#{params[:type]}s") << item unless (@photo.send "#{params[:type]}s").include?(item)
  
    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully added.' }
        format.json { render json: @photo, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end
end
