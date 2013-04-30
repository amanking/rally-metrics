require 'rally_api'

class Rally
  def initialize(user, pass, workspace, project, opts = {})
    @config = {
        :username => user,
        :password => pass,
        :workspace => workspace,
        :project => project,
        :base_url => opts[:rally_base] || "https://rally1.rallydev.com/slm"
    }

    @rally_api = RallyAPI::RallyRestJson.new(@config)
  end

  def stories_in(iteration)
    stories = @rally_api.find do |q|
      q.type = :story
      q.query_string = "((Project.Name = \"#{project}\") and ((Iteration.Name = \"#{iteration}\") and (DirectChildrenCount = \"0\")))"
      q.fetch = "ObjectID,FormattedID,Name,RevisionHistory,PlanEstimate"
      q.project_scope_up = false
      q.project_scope_down = true
    end

    stories.each do |story|
      print_attributes(story, %w{FormattedID Name PlanEstimate})
      print_revisions(story)
      puts "------------------------"
    end

    stories
  end

  def defects_in(iteration)
    defects = @rally_api.find do |q|
      q.type = :defect
      q.query_string = "((Project.Name = \"#{project}\") and (Iteration.Name = \"#{iteration}\"))"
      q.fetch = "ObjectID,FormattedID,Name,RevisionHistory,TaskActualTotal"
      q.project_scope_up = false
      q.project_scope_down = true
    end

    defects.each do |defect|
      print_attributes(defect, %w{ObjectID FormattedID Name TaskActualTotal})
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
    def createdOn(rev)
      rev['CreationDate']
    end

    def description(rev)
      rev['Description']
    end

    puts "Revisions :"
    @rally_api.read(:revision_history, artifact['RevisionHistory']['ObjectID'])['Revisions'].each do |rev|
      puts "#{createdOn(rev)} - #{description(rev)}" if description(rev).include?('SCHEDULE STATE changed from')
    end
  end

  def project
    @config[:project]
  end
end
