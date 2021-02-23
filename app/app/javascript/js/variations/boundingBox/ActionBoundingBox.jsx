import React, { useState, useEffect } from 'react';
import BoundingBox from './BoundingBox.jsx';

const ActionBoundingBox = (props) => {

    //elemType colors: require contrast, so darker tends to be better visually
    const colors = {
        'CLICK' : 'orange'
    };

    const hoverColor = 'blue';
    const color = colors[props.elem.type];

    const actionBboxClickHandler = (elem, rect) => {
        props.bboxClickHandler(props.elem.id);
    };

    return(
        <BoundingBox key={props.elem.id}
                     color={color}
                     hoverColor={hoverColor}

                     elem={props.elem}
                     dim={props.dim}
                     isControl={props.isControl}

                     bboxHoverId={props.bboxHoverId}
                     bboxHoverHandler={props.bboxHoverHandler}
                     bboxClickHandler={actionBboxClickHandler}
        />
    );

}

export default ActionBoundingBox;
