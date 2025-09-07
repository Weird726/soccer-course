#信号总线
extends Node

#准备就绪，可以开始信号
signal kickoff_ready
#创建信号，开球开始
signal Kickoff_started
#队伍重置信号
signal team_reset
#创建一个信号,严格遵守过去式命名，并且使用国家来作为参数
signal team_scored(country_scored_on: String)
