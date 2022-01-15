# frozen_string_literal: true

require_relative "nocion/version"
require "json"
require "nocion/config"
require "rest-client"

module Nocion
  class Database
    Page = Struct.new(:id, :title, :created, :updated, :tag)

    def initialize(key: Config.key, id: nil)
      @id = id
      @header = {content_type: :json, accept: :json, authorization: key, notion_version: '2021-08-16'}
    end

    def retrieve
      resp = RestClient.get("https://api.notion.com/v1/databases/#{@id}", @header)
    end

    def query
      return @pages if @pages
      @pages = []
      @start_cursor = nil
      @has_more = true
      _query while @has_more
      @pages
    end

    private

    def _query
      params = {page_size: 100}
      params[:start_cursor] = @start_cursor if @start_cursor
      resp = RestClient.post("https://api.notion.com/v1/databases/#{@id}/query", params.to_json, @header)

      body = JSON.parse(resp.body)
      @has_more = body['has_more']
      @start_cursor = body['next_cursor']
      body['results'].each do |json|
        @pages << Page.new(
          json['id'],
          json.dig('properties', 'Name', 'title', 0, 'plain_text'),
          json['created_time'],
          json['last_edited_time'],
          json.dig('properties', 'tag', 'multi_select').to_a.map{ |t| t['name'] }
        )
      end
    end
  end

end
