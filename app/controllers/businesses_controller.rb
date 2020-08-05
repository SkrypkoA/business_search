class BusinessesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @businesses = params[:address].present? ? businesses_by_address : []

    respond_to do |format|
      format.json do
        return render json: @businesses.as_json(only: [:address, :city, :state, :zip, :user_id, :place_id, :id, :business_name],
                                                methods: :full_address)
      end
      format.html do
        @options = @businesses.map do |business|
          ["<i class=\"fa fa-building\"/>#{business.address}", business.address]
        end

        @business = Business.new
      end
    end
  end

  def create
    if params[:business][:id].present?
      @business = Business.find(params[:business][:id])
    else
      return redirect_to businesses_path, alert: 'Place is not defined!' unless params[:business][:place_id]

      @business = Business.find_or_initialize_by(place_id: params[:business][:place_id]) do |business|
        place = google_map_client.spot(params[:business][:place_id], details: true)
        business.place_id = place.place_id
        business.business_name = place.name
        business.address = place.formatted_address
        business.city = place.city
        business.state = place.region
        business.zip = place.postal_code
      end
    end

    if @business.user.present?
      flash[:notice] = 'Business already claimed!'
    else
      unless @business.update(user: current_user)
        flash[:alert] = @business.errors.full_messages.joins(', ')
      end
    end

    redirect_to businesses_path
  end

  private

  def google_map_client
    @google_autocomplete ||= GooglePlaces::Client.new(ENV['GOOGLEMAP_KEY'])
  end

  def local_businesses
    Business.where('address ILIKE ?', "%#{params[:address]}%")
  end

  def google_businesses
    places = google_map_client.predictions_by_input(params[:address], types: 'establishment')
    places.map { |place|  Business.build_by_place(place) }
  end

  def businesses_by_address
    case params[:search_type]
    when 'database'
      local_businesses
    when 'google'
      google_businesses
    else
      local_businesses + google_businesses
    end
  end
end
