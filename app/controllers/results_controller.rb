require 'json'
require "erb"
require 'oauth2'
require "base64"
include ERB::Util
class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :edit, :update, :destroy]

  BASE_PATH                   = "https://api.hubapi.com"
  API_KEY_PATH                = "?hapikey=#{ENV['CF_HUBSPOT_API_KEY']}"
  CREATE_UPDATE_CONTACT_PATH  = "/contacts/v1/contact/createOrUpdate/email/:contact_email"

  TOKEN_PATH                  = "https://stars.udonsystems.com/connect/token"
  STARS_BASE_PATH             = "https://stars.udonsystems.com/api"
  STARS_API_KEY_PATH                   = "?username=#{ENV['STARS_CLIENT_ID']}&api_key=#{ENV['STARS_CLIENT_SECRET']}"

  def parse
    puts "###############################################"
    results = params.to_json
    puts JSON.pretty_generate(params)
    puts "###############################################"
    resultIndex = results["quizReport"]["questions"]["yesNoQuestion"]["answers"]["userAnswerIndex"].to_i
    puts results["quizReport"]["questions"]["yesNoQuestion"]["answers"]["answer"][resultIndex]
    puts "###############################################"
    puts hubspotCreateOrUpdateContact("aaron@coderfactory.com", {firstname: "Aaron", lastname: "Test"})
    puts "###############################################"
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    return :status => :ok
    # respond_to do |format|
      # format.json { render :json => {}, :status => :ok }
      # format.xml { render :xml => {}, :status => :ok }
    # end
  end

  def stars
    client_id = ENV['STARS_CLIENT_ID']
    client_secret = ENV['STARS_CLIENT_SECRET']
    credentials = Base64.encode64("#{client_id}:#{client_secret}").gsub("\n", '')
    url = TOKEN_PATH
    body = "grant_type=client_credentials"
    headers = {
      "Authorization" => "Basic #{credentials}",
      "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"
    }
    r = HTTParty.post(url, body: body, headers: headers)
    if r["token_type"] == "Bearer"
      bearer_token = r["access_token"]
    end
    api_auth_header = {"Authorization" => "Bearer #{bearer_token}"}
    url = "#{STARS_BASE_PATH}/languages"
    puts HTTParty.get(url, headers: api_auth_header).body
  end

  # GET /results
  # GET /results.json
  def index
    @data = params[:r]
    @results = Result.all
    puts hubspotCreateOrUpdateContact("aaron@coderfactory.com", {firstname: "Aaron", lastname: "Test"})
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
    url = "#{BASE_PATH}#{CREATE_UPDATE_CONTACT_PATH.gsub(/:contact_email/, email)}#{API_KEY_PATH}"
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
