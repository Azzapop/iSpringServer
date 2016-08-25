require 'json'
class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :edit, :update, :destroy]

  BASE_PATH                  = "https://api.hubapi.com"
  API_KEY_PATH               = "?hapikey=#{ENV['CF_HUBSPOT_API_KEY']}"
  CREATE_UPDATE_CONTACT_PATH = "/contacts/v1/contact/createOrUpdate/email/:contact_email"

  def parse
    puts "###############################################"
    results = JSON.parse(Hash.from_xml(params["dr"]).to_json)
    puts JSON.pretty_unparse(results)
    puts "###############################################"
    resultIndex = results["quizReport"]["questions"]["yesNoQuestion"]["answers"]["userAnswerIndex"].to_i
    puts results["quizReport"]["questions"]["yesNoQuestion"]["answers"]["answer"][resultIndex]
    puts "###############################################"
    puts hubspotCreateOrUpdateContact("aaron@coderfactory.com", {firstname: "Aaron", lastname: "Hook"})
    puts "###############################################"
  end

  # GET /results
  # GET /results.json
  def index
    @results = Result.all
  end

  # GET /results/1
  # GET /results/1.json
  def show
  end

  # GET /results/new
  def new
    @result = Result.new
  end

  # GET /results/1/edit
  def edit
  end

  # POST /results
  # POST /results.json
  def create
    @result = Result.new(result_params)

    respond_to do |format|
      if @result.save
        format.html { redirect_to @result, notice: 'Result was successfully created.' }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results/1
  # PATCH/PUT /results/1.json
  def update
    respond_to do |format|
      if @result.update(result_params)
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result.destroy
    respond_to do |format|
      format.html { redirect_to results_url, notice: 'Result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_result
    @result = Result.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def result_params
    params.fetch(:result, {})
  end

  def hubspotCreateOrUpdateContact(email, params)
    url = "#{BASE_PATH}#{CREATE_UPDATE_CONTACT_PATH.gsub(/:email/, email)}#{API_KEY_PATH}"
    contact_hash = get_hash(params)
    @result = HTTParty.post(url, body: contact_hash.to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
    return @result
  end

  def get_hash(params)
    properties = []
    params.each do |key, data|
      hash = {"property" => key, "value" => data}
      properties << hash
    end
    return {"properties" => properties}
  end
end
