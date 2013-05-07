require 'rally_api'
require 'unit_of_work'
require 'revs_parser'

module Rally
  REV_TEXT_REGEX = /SCHEDULE STATE changed from \[(?<from>.+?)\] to \[(?<to>.+?)\]/

  class RallyClient
    @@base_query = {
        :order => "CreationDate asc",
        :project_scope_up => false,
        :project_scope_down => true
    }

    def initialize(user, pass, workspace, project, opts = {})
      @config = {
          :username => user,
          :password => pass,
          :workspace => workspace,
          :project => project,
          :base_url => opts[:rally_base] || "https://rally1.rallydev.com/slm"
      }

      @rally_api = RallyAPI::RallyRestJson.new(@config)
      @revs_parser = RevsParser.new
    end

    def iteration(date)
      query = RallyAPI::RallyQuery.new(@@base_query.merge({
          :type => :iteration,
          :query_string => "((Project.Name = \"#{project}\") and ((StartDate <= \"#{date.strftime('%F')}\") and (EndDate >= \"#{date.strftime('%F')}\")))",
          :fetch => "ObjectID,FormattedID,Name,StartDate,EndDate"
      }))

      @rally_api.find(query).first['Name']
    end

    def stories(iteration)
      query = RallyAPI::RallyQuery.new(@@base_query.merge({
          :type => :story,
          :query_string => "((Project.Name = \"#{project}\") and ((Iteration.Name = \"#{iteration}\") and (DirectChildrenCount = \"0\")))",
          :fetch => "ObjectID,FormattedID,CreationDate,Name,RevisionHistory,PlanEstimate"
      }))

      @rally_api.find(query).map do |s|
        UnitOfWork.new(s['FormattedID'], s['Name'], s['PlanEstimate'], @revs_parser.parse(get_revisions(s)))
      end
    end

    def defects(iteration)
      query = RallyAPI::RallyQuery.new(@@base_query.merge({
          :type => :defect,
          :query_string => "((Project.Name = \"#{project}\") and (Iteration.Name = \"#{iteration}\"))",
          :fetch => "ObjectID,FormattedID,Name,CreationDate,RevisionHistory,TaskActualTotal"
      }))

      @rally_api.find(query).map do |d|
        UnitOfWork.new(d['FormattedID'], d['Name'], d['TaskActualTotal'], @revs_parser.parse(get_revisions(d)))
      end
    end

    private

    def get_revisions(artifact)
      revision_history = @rally_api.read(:revision_history, artifact['RevisionHistory']['ObjectID'])

      revision_history['Revisions'].map do |rev|
        description = rev['Description']
        Rally::REV_TEXT_REGEX =~ description ? "#{rev['CreationDate']} | #{description}" : nil
      end.compact
    end

    def project
      @config[:project]
    end
  end
end
