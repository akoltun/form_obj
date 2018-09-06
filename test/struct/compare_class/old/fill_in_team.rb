module FillInTeam
  def fill_in_team(team)
    team.name = 'Ferrari'
    team.year = 1950

    car = team.cars.create
    car.code = '340 F1'
    car.driver = 'Ascari'
    car.engine.power = 335
    car.engine.volume = 4.1
    car.chassis.suspension.front = 'independent'
    car.chassis.suspension.rear = 'de Dion'
    car.chassis.brakes = :drum

    car = team.cars.create
    car.code = '275 F1'
    car.driver = 'Villoresi'
    car.engine.power = 300
    car.engine.volume = 3.3
    car.chassis.suspension.front = 'dependent'
    car.chassis.suspension.rear = 'de Lion'
    car.chassis.brakes = :disc

    colour = team.colours.create
    colour.name = :red
    colour.rgb = 0xFF0000

    colour = team.colours.create
    colour.name = :white
    colour.rgb = 0xFFFFFF

    team
  end
end
