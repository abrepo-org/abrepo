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
            position: 'absolute',
            width: '100%',
            height: 'max-content',

            //border: '1px solid #000',
        };

        return (
            <div className="scrollbar is-hidden-touch is-hidden-desktop-only"
                 style={scrollBarStyle}
                 ref={this.scrollBarRef}>
                {this.props.children}
            </div>
        );
    }
}
