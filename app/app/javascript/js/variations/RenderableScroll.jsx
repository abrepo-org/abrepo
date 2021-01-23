import React from 'react';
import ReactDOM from 'react-dom';

export default class RenderableScroll extends React.Component {

    constructor(props) {
        console.log("RenderableScroll");
        super(props);

        this.scrollBarRef = React.createRef();
    }


    wheelHandler(e) {
        e.preventDefault();
        //TODO: add debounce
        console.log(e);
        this.props.scrollListener(e.deltaY);
    }

    componentDidMount() {
        this.scrollBarRef.current.addEventListener('wheel', this.wheelHandler.bind(this));
    }

    componentWillUnmount() {
        this.scrollBarRef.current.removeEventListener('wheel', this.wheelHandler.bind(this));
    }

    render() {
        const scrollBarStyle = {
            height: '100%',
            width: '24px',
            border: '1px solid #000',
            marginTop: '2.25rem',
            //dynamic
            height: 'calc(2420px - 2.25rem - 4px)'
        };

        return (
            <div className="scrollbar is-hidden-touch is-hidden-desktop-only"
                 style={scrollBarStyle}
                 ref={this.scrollBarRef}></div>
        );
    }
}
