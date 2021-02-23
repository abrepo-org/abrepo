import React, { useState, useEffect } from 'react';
import BoundingBox from './BoundingBox.jsx';

const DiffBoundingBox = (props) => {
    //elemType colors: require contrast, so darker tends to be better visually
    const colors = {
        'ADDED': 'green',
        'CHANGED': 'blueviolet',
        'REMOVED': 'red',
    };

    const hoverColor = 'blue';

    const color = colors[props.elem.type]

    return(
        <BoundingBox key={props.elem.id}
                     color={color}
                     hoverColor={hoverColor}

                     elem={props.elem}
                     dim={props.dim}
                     isControl={props.isControl}

                     bboxHoverId={props.bboxHoverId}
                     bboxHoverHandler={props.bboxHoverHandler}
                     bboxClickHandler={props.bboxClickHandler}
        />
    );
}

export default DiffBoundingBox;
