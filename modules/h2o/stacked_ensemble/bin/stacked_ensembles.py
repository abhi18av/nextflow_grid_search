def extract_params_from_model(actual_params_dict, extra_params = [], additional_keys = {}):
    final_params = actual_params_dict

    columns_to_be_removed =   [
                                'model_id',
                                'validation_frame',
                                'response_column',
                                'ignored_columns',
                                'training_frame',
                                *extra_params
]

    for col_name in columns_to_be_removed:
        del  final_params[col_name]

    return {**final_params, **additional_keys}
