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
    if yays.length == nays.length
      rando_num = _.random(0, BIG_VOTE.length-1)
      rando = BIG_VOTE[rando_num]
      message_payload = "It was a TIE! So I have picked at random one of the voters: #{rando.user}. S/he gets to decide!"
    else
      winner = if yays.length > nays.length then "The yays have it" else "The nays have it"
      message_payload = "Voting has stopped for: #{vote_message}\n"
      message_payload += "It was #{yays.length} for yes and #{nays.length} for no.\n"
      message_payload += "With a total of #{total} votes.\n#{winner}"
    message_payload

  vote_helper = (msg, are_we_voting, outcome) ->
    if(are_we_voting)
      message_payload = "#{outcome} vote registered from: "+msg.message.user.name
      existing_vote = _.findWhere(BIG_VOTE, {user: msg.message.user.name})
      if(existing_vote)
        unless existing_vote.vote is outcome
          message_payload += '\nUh oh, '+msg.message.user.name+ ' switched his/her vote!'
        else
          message_payload += '\nUgh, I already got your vote. Stop spamming'
        existing_vote.vote = outcome
      else
        BIG_VOTE.push({user: msg.message.user.name, vote: outcome})
    else
      message_payload = msg.message.user.name + ", we're not voting anymore"
    message_payload

  robot.respond /reset vote/i, (msg) ->
    robot.brain.set("are_we_voting", false)
    status = robot.brain.get('are_we_voting')
    unless status
      BIG_VOTE = []
      msg.send "I have successfully reset the vote"
    else
      msg.send "Something weird happened. Blame :doyle:"

  robot.respond /vote: (.*)/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")

    unless are_we_voting
      BIG_VOTE = []
      robot.brain.set("are_we_voting", true)
      message_payload = msg.message.user.name + " is starting a vote:\n"
      message_payload += msg.match[1] + "\n"
      message_payload += "Reply in the next #{VOTE_TIMER} seconds: yes or no"
      msg.send message_payload

      setTimeout (->
        if robot.brain.get("are_we_voting")
          robot.brain.set("are_we_voting", false)
          msg.send broadcast_voting_results(msg.match[1])
        else
          msg.send 'The vote was canceled :sadpanda:'
      ), VOTE_TIMER*1000

  robot.respond /yes/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")
    msg.send vote_helper(msg, are_we_voting, 'yes')

  robot.respond /no/i, (msg) ->
    are_we_voting = robot.brain.get("are_we_voting")
    msg.send vote_helper(msg, are_we_voting, 'no')