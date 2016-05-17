module Lita
  module Handlers
    class Balance < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team balance$/i,
        :balance,
        command: true,
        help: {
          "<name> team balance" => "Balance a given team."
        }
      )

      def balance(response)
        team_name = response.match_data[1]
        if team = get_team(team_name)
          if members_even?(team, response)
            if team_scores = get_member_scores(team, response)
              balanced = begin
                balance_group(team_scores.to_a)
              rescue
                balance_group(team_scores.to_a)
              end
              blue_team = balanced[0][:group] ; red_team = balanced[1][:group]
              blue_team.map! { |member| member.first }
              red_team.map! { |member| member.first }
              response.reply(render_template(:balanced_teams, teams: blue_team.zip(red_team)))
            end
          end
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      private

      def get_member_scores(team, response)
        memeber_scores = {} ; missed_score = [] ; current_team_members = []
        team[:members].each_key { |key| current_team_members << key.to_s }
        current_team_members.each do |member_name|
          member_score = redis.get("scores:soccer:#{member_name}")
          if member_score
            memeber_scores[member_name] = member_score.to_i
          else
            missed_score << member_name
          end
        end
        if missed_score.any?
          response.reply(
            render_template(
              :missing_scores,
              team_name: team[:name],
              missing: missed_score
            )
          )
          return nil
        end
        return memeber_scores
      end

      def members_even?(team, response)
        if team[:members].count.odd?
          response.reply(render_template(:team_not_even, team_name: team[:name], count: team[:members].count))
          return false
        end
        true
      end

      # thanks robertomiranda: https://gist.github.com/robertomiranda/a5b6e250fa0ad355b277dfe2bed7e267
      def balance_group(members)
        group1, group2 = members.shuffle.in_groups(2)
        mean1 = (group1.map { |score| score[1] }.inject(:+)/group1.size.to_f)
        mean2 = (group2.map { |score| score[1] }.inject(:+)/group2.size.to_f)
        if mean1.to_i ==  mean2.to_i
          return [{mean: mean1, group: group1}, {mean: mean2, group: group2}]
        else
          balance_group(members.shuffle)
        end
      end

      Lita.register_handler(self)
    end
  end
end