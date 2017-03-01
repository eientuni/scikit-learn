from __future__ import division, print_function


def _impurity_mse(stats_node):
    """Compute the impurity in MSE sense

    Parameters
    ----------
    stats_node: StatsNode,
        The split record from which to compute the impurity

    Returns
    -------
    impurity: float,
        The impurity.
    """
    impurity = (stats_node.sum_sq_y /
                stats_node.sum_weighted_samples)
    impurity -= ((stats_node.sum_y /
                  stats_node.sum_weighted_samples) ** 2.0)

    return impurity


def impurity_improvement(c_split_record, sum_total_weighted_samples,
                         criterion='mse'):
    """Compute the impurity improvement.

    Parameters
    ----------
    c_split_record: SplitRecord,
        Split record of the current node.

    sum_total_weighted_samples: float,
        The sum of all the weights for all samples.

    criterion: str, optional(default='mse')
        The criterion to use to compute the impurity improvement.

    Returns
    -------
    impurity_improvement: float,
        Impurity improvement
    """
    if criterion == 'mse':
        _impurity_func = _impurity_mse
    else:
        raise NotImplementedError

    # check that there is more sample in the root nodes than
    # in the current nodes
    if ((sum_total_weighted_samples <
         c_split_record.c_stats.sum_weighted_samples) or
        (sum_total_weighted_samples <
         c_split_record.l_stats.sum_weighted_samples) or
        (sum_total_weighted_samples <
         c_split_record.r_stats.sum_weighted_samples)):
        raise ValueError('The number of samples in the root nodes is'
                         ' less than in the current children node.')

    # impurity current node
    c_impurity = _impurity_func(c_split_record.c_stats)
    # impurity left child
    l_impurity = _impurity_func(c_split_record.l_stats)
    # impurity right child
    r_impurity = _impurity_func(c_split_record.r_stats)

    return ((c_split_record.c_stats.sum_weighted_samples /
             sum_total_weighted_samples) *
            (c_impurity -
             (c_split_record.l_stats.sum_weighted_samples /
              sum_total_weighted_samples * l_impurity) -
             (c_split_record.r_stats.sum_weighted_samples /
              sum_total_weighted_samples * r_impurity)))
