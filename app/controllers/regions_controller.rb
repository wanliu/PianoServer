class RegionsController < ApplicationController

  def set
    cookies[:region_id] = {
      :value => params[:region_id],
      :expires => 1.year.from_now
    }

    redirect_to callback_url || root_path
  end

  def retrive
    @status = 200

    province, province_id = ChinaCity.list.find {|city, id| city == params[:province] }

    if province
      city, city_id = ChinaCity.list(province_id).find {|city, id| city == params[:city] }
      if city
        region, region_id = ChinaCity.list(city_id).find {|city, id| city == params[:region] }
      end
    end

    @results = {
      success: true,
      province_id: province_id,
      city_id: city_id,
      region_id: region_id,
      html: render_to_string(partial: "city_select", layout: false, locals: {province_id: province_id, city_id: city_id, region_id: region_id })
    }
  rescue
    @results = {
      error: 'invalid region name'
    }

    @status = 500
  ensure
    render json: @results, status: @status
  end

  private

  def callback_url
    params[:callback] || session[:callback]
  end
end
