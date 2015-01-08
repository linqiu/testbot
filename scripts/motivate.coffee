# Description:
# Let's spread some joy!
#
# Commands:
#   hubot motivate me

module.exports = (robot) ->
  robot.respond /motivate me/i, (msg) ->
    robot.http("http://pleasemotivate.me/api")
      .get() (err, res, body) ->
        response = JSON.parse(body)
        msg.send response.motivation
