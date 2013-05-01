require 'rally_api'
require 'story'
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
        Story.new(s['FormattedID'], s['Name'], s['PlanEstimate'], @revs_parser.parse(get_revisions(s)))
      end
    end

    def defects(iteration)
      defects = @rally_api.find do |q|
        q.type = :defect
        q.query_string = "((Project.Name = \"#{project}\") and (Iteration.Name = \"#{iteration}\"))"
        q.fetch = "ObjectID,FormattedID,Name,RevisionHistory,TaskActualTotal"
        q.project_scope_up = false
        q.project_scope_down = true
      end

      defects.each do |defect|
        print_attributes(defect, %w{FormattedID Name TaskActualTotal})
        print_revisions(defect)
        puts "------------------------"
      end

      defects
    end

    private

    def print_attributes(artifact, attributes)
      attributes.each do |attr|
        puts "#{attr} : #{artifact[attr]}"
      end
    end

    def print_revisions(artifact)
      puts "Revisions : \n#{get_revisions(artifact).join("\n")}"
    end

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
