# Description:
# Take yes or no votes
#
# Commands:
#   hubot vote: Kushi for lunch?
Util = require "util"
_ = require "lodash"
BIG_VOTE = []
VOTE_TIMER = 60

module.exports = (robot) ->

  broadcast_voting_results = (vote_message) ->
    # it returns the vote results
    yays = _.filter(BIG_VOTE, {vote: 'yes'})
    nays = _.filter(BIG_VOTE, {vote: 'no'})
    total = yays.length + nays.length
    winner = if yays.length > nays.length then "The yays have it" else "The nays have it"
    winner = "OMG IT'S A TIE" if yays.length == nays.length
    "Results for #{vote_message} was #{yays.length} for yes and #{nays.length} for no. With a total of #{total} votes. #{winner}"

  robot.respond /reset vote/i, (msg) ->
    robot.brain.set("are_we_voting", false)
    status = robot.brain.get('are_we_voting')
    msg.send 'reset vote: ' + status

  robot.respond /vote: (.*)/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")

    unless are_we_voting
      BIG_VOTE = []
      robot.brain.set("are_we_voting", true)
      msg.send msg.message.user.name + " is starting a vote: "
      msg.send msg.match[1] + "\n"
      msg.send "reply in the next #{VOTE_TIMER} seconds yes or no"

      setTimeout (->
        robot.brain.set("are_we_voting", false)
        msg.send "Voting has stopped for: "+msg.match[1]
        msg.send broadcast_voting_results(msg.match[1])
      ), VOTE_TIMER*1000

  robot.respond /yes/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")
    if(are_we_voting)
      msg.send 'yes vote registered from: '+msg.message.user.name
      exist_vote = _.findWhere(BIG_VOTE, {user: msg.message.user.name})
      if(exist_vote)
        exist_vote.vote = 'yes'
        msg.send 'uh oh, '+msg.message.user.name+ ' switched his/her vote!'
      else
        BIG_VOTE.push({user: msg.message.user.name, vote: "yes"})
    else
      msg.send msg.message.user.name + ", we're not voting anymore"

  robot.respond /no/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")
    if(are_we_voting)
      msg.send 'no vote registered from: '+msg.message.user.name
      exist_vote = _.findWhere(BIG_VOTE, {user: msg.message.user.name})
      if(exist_vote)
        exist_vote.vote = 'no'
        msg.send 'uh oh, '+msg.message.user.name+ ' switched his/her vote!'
      else
        BIG_VOTE.push({user: msg.message.user.name, vote: "no"})
    else
      msg.send msg.message.user.name + ", we're not voting anymore"