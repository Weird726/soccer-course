#信号总线
extends Node

#球的拥有者
signal ball_possessed(player_name: String)
#球的拥有者公布
signal ball_released
#游戏结束事件(参数传入获胜国家)
signal game_over(country_winner: String)
#准备就绪，可以开始信号
signal kickoff_ready
#创建信号，开球开始
signal Kickoff_started
#分数变化信号
signal score_changed
#队伍重置信号
signal team_reset
#创建一个信号,严格遵守过去式命名，并且使用国家来作为参数
signal team_scored(country_scored_on: String)
