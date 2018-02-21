function PLOT_ALL( S )

ffprintf('Plotting... \n')

ADAPT.Stats.plot_trajectories     ( S )
ADAPT.Stats.plot_evolution_inBlock( S )
ADAPT.Stats.plot_stat_by_reward   ( S )
ADAPT.Stats.plot_stat_by_target   ( S )

ffprintf('... done \n')

end % function
