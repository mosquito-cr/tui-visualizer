# ┌───┐
# │   │
# ├───┼─
# │   │
# └───┘

class MosquitoInterface < Keimeno::Base
  @queues : Array(Mosquito::Queue)
  @last_update : Time

  def initialize
    @full_screen = true
    @queues = [] of Mosquito::Queue
    @last_update = Time::UNIX_EPOCH
  end

  INTERVAL = 0.2.seconds

  # In this case, input comes from the mosquito api, not from the keyboard
  def wait_for_input
    now = Time.utc
    dwell = now - @last_update

    if dwell > INTERVAL
      @last_update = now

      Mosquito.backend.list_queues
        .map { |name| Mosquito::Queue.new name }
        .reject { |q| @queues.includes? q }
        .each { |q| @queues.push q }
    else
      sleep_time = INTERVAL - dwell
      # puts "sleeping for: #{sleep_time}"
      sleep sleep_time
    end
  end

  def display
    banner

    @queues.each.with_index do |queue, index|
      if index == 0
        print "┌"
      else
        print "├"
      end

      puts "#{queue.name} (Q)"

      task_ids = [] of {String, String} # task, status

      {% for name in ["waiting", "scheduled", "pending", "dead"] %}
        queue.backend.dump_{{name.id}}_q.each do |task_id|
          task_ids << {task_id, {{ name }}}
        end
      {% end %}

      tasks = task_ids.compact_map do |task_id, status|
        retrieved_task = Mosquito::Task.retrieve(task_id)

        if retrieved_task
          {retrieved_task, status}
        else
          nil
        end
      end

      last_index = tasks.size - 1
      tasks.each_with_index do |(task, status), index|
        if index == last_index
          print "│└"
        else
          print "│├"
        end

        puts "#{task.id} (#{task.type}, #{status}, enqueued #{decode_time_ago task.enqueue_time})"
      end

      puts "│"
    end
  end

  def banner
    puts "┌───────────────────────────────────────┐"
    puts "│ Mosquito Primitive Backend Visualizer │"
    puts "└───────────────────────────────────────┘"
  end

  def decode_time_ago(time)
    time_ago = Time.utc - time

    if time_ago < 3.seconds
      "just now"
    elsif time_ago < 1.hour
      "#{time_ago.to_i} seconds ago"
    elsif time_ago < 1.day
      "#{time_ago.hours} hours ago"
    elsif time_ago < 1.week
      "#{time_ago.days} days ago"
    elsif time_ago < 4.weeks
      "#{time_ago.days / 7} weeks ago"
    elsif time_ago < 52.weeks
      "#{time_ago.days / 30} months ago"
    else
      "#{time_ago.days / 365} years ago"
    end
  end
end
