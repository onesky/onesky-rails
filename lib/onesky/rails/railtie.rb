module Onesky
  module Rails

    class Railtie < ::Rails::Railtie
      railtie_name :onesky

      rake_tasks do
        load "tasks/onesky.rake"
      end
    end

  end
end