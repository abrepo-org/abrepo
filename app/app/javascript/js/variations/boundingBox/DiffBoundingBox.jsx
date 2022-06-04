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

    const color = colors[props.elem.type];

    //click wrapper to extract diff's rect before passing it
    //to prop handler in index.jsx
    const diffBboxClickHandler = (elem) => {

        const rect = elem.ref &&
              elem.ref.current &&
              elem.ref.current.getClientRects()[0];

        //this is index.jsx:diffBboxClickHandler
        //renderableContainer -> index.jsx
        props.bboxClickHandler(elem, rect);
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
                     bboxClickHandler={diffBboxClickHandler}
        />
    );
}

export default DiffBoundingBox;
