import React, { useState, useEffect } from 'react';

//isControl, dim, dim.boundingbox, elem, color
const MaskBoundingBox = (props) => {

    // if there is no bbox (e.g. SCRIPT) we currently return null
    if (props.dim && !props.dim.isVisible) return null;

    //style settings
    const lineWidth = 3;
    const hoverLineWidth = 3;


    //data
    const id = (props.isControl ? "c-mask-" : "mask-") + props.elem.id;
    const dim = props.dim;
    const boundingBox = dim.boundingBox;

    if (!boundingBox) return null;

    const coord = boundingBox.rect;

    return (
        <rect
            id={`svgRect-${id}`}
            x={coord.x - lineWidth}
            y={coord.y - lineWidth}
            width={coord.width + lineWidth}
            height={coord.height + lineWidth}
        />
    );
};

export default MaskBoundingBox;
