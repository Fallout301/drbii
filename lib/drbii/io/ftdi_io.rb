require 'timeout'
require 'ftdic'
require 'logger'

class FtdiIO
  def initialize(dev, bitbang=true)
    @ftdi = FtdiC::Context.new
    @ftdi.open(dev)
    @logger = Logger.new(STDOUT)

    if bitbang then
      @ftdi.set_bitmode(0xFF, FtdiC::BITMODE_SYNCBB)
    end
  end

  def baudrate=(baud)
    @logger.info "Setting baud rate to #{baud}"
    @ftdi.baudrate = baud
  end

  def read(n)
    @logger.info "Reading"
    s = @ftdi.read_data(n)
    @logger.info "Read #{s.inspect}"
    return s
  end

  def read_timeout(n, t)
    return io_timeout(t) { read(n) }
  end

  def write(s)
    @logger.info "Writing #{s.inspect}"
    return @ftdi.write_data(s)
  end

  def write_timeout(s, t)
    return io_timeout(t) { write(s) }
  end

  def io_timeout(t=1, &block)
    begin
      return timeout(t, &block)
    rescue TimeoutError
      @logger.info "Timeout after #{t} seconds"
    end
  end
end

