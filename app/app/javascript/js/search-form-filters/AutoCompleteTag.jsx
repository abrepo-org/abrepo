import React, { useState, useEffect } from 'react';

export const AutoCompleteTag = (props) => {

    const clickHandler = (e) => {

        //add to input selection
        props.addTag(props.tag);

        //clear
        props.clearSelected(props.tag);
    };

    const styleLi = {
        cursor: 'pointer'
    };

    return (
        <li className="tag"
            style={styleLi}
            onClick={(e) => clickHandler(e)}>
            {props.tag}
        </li>
    );
};
