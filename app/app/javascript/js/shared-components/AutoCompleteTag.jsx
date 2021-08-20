import React, { useState, useEffect } from 'react';

export const AutoCompleteTag = (props) => {

    const clickHandler = (e) => {
        //add to input selection
        props.addTag(props.tag);

        //clear
        props.clearSelected();
    };

    return (
        <li className="tag" onClick={(e) => clickHandler(e)}>
          {props.tag}
        </li>
    );
};
