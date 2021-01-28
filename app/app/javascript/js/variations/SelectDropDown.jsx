import React, { useState, useEffect } from 'react';

const SelectDropDown = (props) => {

    const isVisible = props.isSingleView ? "is-visibile": "is-invisible";

    const handleChange = (e) => {
        props.toggleActiveViewHandler(!!parseInt(e.target.value));
    };

    return(
        <div className={`select is-small ${isVisible}`}>
          <select onChange={handleChange}>
            <option value='1'>Variation</option>
            <option value='0'>Baseline</option>
          </select>
        </div>
    );

};

export default SelectDropDown;
