import React from 'react';
import ReactDOM from 'react-dom';

export default class Button extends React.Component {

    constructor(props) {
        super(props);
        console.log("button constructor");
    }

    async clickHandler(e) {
        console.log("click!");
        const url = '/imports/test';
        const input = {test: 123};
        
        const res = await fetch(url, {
            method: "POST",
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({input})
        }).then(res => { return res.json(); });

        console.log("RES", res);
    }

    render() {
        return( <button onClick={this.clickHandler.bind(this)}>
                {this.props.children}
                </button>);
    }

}
