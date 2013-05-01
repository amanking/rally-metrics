require 'rally_api'
require 'unit_of_work'
require 'revs_parser'

module Rally
  REV_TEXT_REGEX = /SCHEDULE STATE changed from \[(?<from>.+?)\] to \[(?<to>.+?)\]/

  class RallyClient
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

    def stories(iteration)
      stories = @rally_api.find do |q|
        q.type = :story
        q.query_string = "((Project.Name = \"#{project}\") and ((Iteration.Name = \"#{iteration}\") and (DirectChildrenCount = \"0\")))"
        q.fetch = "ObjectID,FormattedID,CreationDate,Name,RevisionHistory,PlanEstimate"
        q.order = "CreationDate asc"
        q.project_scope_up = false
        q.project_scope_down = true
      end

      stories.map do |s|
        UnitOfWork.new(s['FormattedID'], s['Name'], s['PlanEstimate'], @revs_parser.parse(get_revisions(s)))
      end
    end

    def defects(iteration)
      defects = @rally_api.find do |q|
        q.type = :defect
        q.query_string = "((Project.Name = \"#{project}\") and (Iteration.Name = \"#{iteration}\"))"
        q.fetch = "ObjectID,FormattedID,Name,CreationDate,RevisionHistory,TaskActualTotal"
        q.order = "CreationDate asc"
        q.project_scope_up = false
        q.project_scope_down = true
      end

      defects.map do |d|
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
