import React, { useState, useEffect } from 'react';

export const Test = (props) => {

    const clickHandler = () => {
        console.log("hi", props.dataset.id);

    };

    return <button onClick= {() => clickHandler() }>test</button>;
};

export default Test;
