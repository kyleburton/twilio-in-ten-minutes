
namespace :ivr do
  desc "Render Workflow PNGs"
  task :render_workflows do
    Dir.glob("app/ivr_workflows/*.rb").each do |f|
      res = require f
      puts "ivr workflow:#{f} => #{res.inspect}"
      clazz = res.first.constantize
      wkflow = clazz.new
      dot_file = File.basename(f)
      dot_file.sub! /.rb$/, '.dot'
      dot_file = "public/workflows/#{dot_file}"
      out_dir = "public/workflows"
      if !File.exist? out_dir
        Dir.mkdir out_dir
      end
      File.open(dot_file,"w") do |outp|
        outp.write wkflow.workflow.to_dotty
      end
      png_file = dot_file.sub /.dot$/, '.png'
      cmd = "dot -Tpng #{dot_file} > #{png_file}"
      puts cmd
      system cmd
    end
  end
end

