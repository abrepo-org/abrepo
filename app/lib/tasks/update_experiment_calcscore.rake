namespace :abrepo do
  desc "Update all Experiment models with calcscore"
  #NB: ':environment' indicates dependency to allow access to models
  task :experiment_calcscore => :environment do
    experiments = Experiment.all
    experiments.each do |e|

      e.update(calcscore: e.score)
      puts e.calcscore

      #puts "#{e.id}, #{numDiffs}, #{avgDiffs}, | \
      ##{numRenderables}, #{avgRenderables} | #{avgDiffs / avgRenderables} -> #{ascore}"
    end
  end
end
