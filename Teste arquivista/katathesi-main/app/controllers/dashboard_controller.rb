class DashboardController < ApplicationController
  layout "dashboard"

  def index
    @meses = [ "JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ" ]
    @receitas_mensais = [ 5000, 4500, 4700, 5200, 4100, 4800, 4600, 5000, 4200, 4900, 4100, 4700 ]
    @despesas_mensais = [ 3000, 3100, 3200, 2800, 3900, 3300, 3500, 3700, 3000, 2900, 2700, 3300 ]
    @saldos_mensais = [ 4000, 3400, 2100, 3800, 3700, 4400, 5500, 6100, 5700, 7200, 7400, 7700 ]

    render "home/index"
  end
end
