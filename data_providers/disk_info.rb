class DataProviders::DiskInfo
  def initialize
    @reads_sec = 0
    @writes_sec = 0

    Thread.new do
      last_time = last_reads = last_writes = 0
      first_time = true
      while(true)
        time = (Time.new.to_f * 1000).to_i

        reads, writes = IO.readlines("/proc/diskstats").map { |l| parts = l.split; [parts[5].to_i, parts[7].to_i] }.inject([0, 0]) { |sum, vals| [sum[0] + vals[0], sum[1] + vals[1]] }

        if first_time
          first_time = false
        else
          @reads_sec = ((reads - last_reads) / ((time - last_time).to_f / 1000.0)) * 512
          @writes_sec = ((writes - last_writes) / ((time - last_time).to_f / 1000.0)) * 512
        end
        last_reads = reads
        last_writes = writes
        last_time = time
        sleep(1)
      end
    end
  end

  def get
    { :reads => @reads_sec, :writes => @writes_sec }
  end
end